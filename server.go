package main

import (
	"log"
	"net/http"
	"os"
	"slices"

	"github.com/fsnotify/fsnotify"
	"github.com/gorilla/websocket"
)

func (w *MyWatcher) removeClient(c *Client) {
	idx := slices.Index(w.clients, c)
	if idx == -1 {
		return
	}

	w.clients = slices.Delete(w.clients, idx, idx+1)
}

type Client struct {
	events chan *WSMessage
	errors chan *WSError
	conn   *websocket.Conn
	w      *MyWatcher
}

type MyWatcher struct {
	watcher            *fsnotify.Watcher
	clients            []*Client
	lastVertexShader   string
	lastFragmentShader string
}

type WSMessage struct {
	Name   string `json:"name"`
	Shader string `json:"shader"`
}

type WSError struct {
	Error string `json:"error"`
}

func main() {
	watcher, err := fsnotify.NewWatcher()
	if err != nil {
		log.Fatal("Failed to create new watcher")
	}

	err = watcher.Add("./shaders")
	if err != nil {
		log.Fatal("Failed to start monitoring shader folder")
	}

	myWatcher := &MyWatcher{
		watcher: watcher,
		clients: make([]*Client, 0, 3),
	}

	go myWatcher.run()

	http.Handle("/static/", http.StripPrefix("/static/", http.FileServer(http.Dir("./static"))))
	http.HandleFunc("/", homeHandler)

	http.HandleFunc("/ws", websocketHandler(myWatcher))

	log.Println("Listening on 8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}

func (w *MyWatcher) run() {
	content, err := os.ReadFile("shaders/vertex.glsl")
	if err != nil {
		log.Fatal("Failed reading shaders/vertex.glsl")
	}

	w.lastVertexShader = string(content)

	content, err = os.ReadFile("shaders/fragment.glsl")
	if err != nil {
		log.Fatal("Failed reading shaders/fragment.glsl")
	}

	w.lastFragmentShader = string(content)

	log.Println("Watcher resumption complete, watching for changes...")

	for {
		evt := <-w.watcher.Events
		log.Println(evt)

		switch evt.Op {

		case fsnotify.Write:
			log.Printf("%s updated. Broadcasting new content...", evt.Name)
			shader, err := os.ReadFile(evt.Name)

			if err != nil {
				msg := &WSError{
					Error: err.Error(),
				}

				for _, client := range w.clients {
					client.errors <- msg
				}
			} else {
				msg := &WSMessage{
					Name:   evt.Name,
					Shader: string(shader),
				}

				for _, client := range w.clients {
					client.events <- msg
				}
			}
		}
	}
}

func websocketHandler(watcher *MyWatcher) http.HandlerFunc {

	return func(w http.ResponseWriter, r *http.Request) {
		upgrader := websocket.Upgrader{
			ReadBufferSize:  1024,
			WriteBufferSize: 1024,
		}

		conn, err := upgrader.Upgrade(w, r, nil)

		if err != nil {
			log.Println(err)
			w.WriteHeader(http.StatusInternalServerError)
			w.Write([]byte(err.Error()))
			return
		}

		client := &Client{
			events: make(chan *WSMessage),
			errors: make(chan *WSError),
			conn:   conn,
		}

		watcher.clients = append(watcher.clients, client)

		go client.websocketRun()
	}
}

func (c *Client) websocketRun() {
	defer c.conn.Close()

	files, err := os.ReadDir("./shaders")

	if err != nil {
		msg := WSError{Error: err.Error()}
		c.conn.WriteJSON(msg)
		return
	}

	for _, file := range files {
		shader, err := os.ReadFile("./shaders/" + file.Name())

		if err != nil {
			msg := WSError{
				Error: err.Error(),
			}
			c.conn.WriteJSON(msg)
			continue
		}

		msg := WSMessage{
			Name:   file.Name(),
			Shader: string(shader),
		}

		c.conn.WriteJSON(msg)
	}

	for {
		select {
		case msg := <-c.events:
			c.conn.WriteJSON(msg)
		case msg := <-c.errors:
			c.conn.WriteJSON(msg)
		}
	}
}

func homeHandler(w http.ResponseWriter, r *http.Request) {
	http.ServeFile(w, r, "./index.html")
}
