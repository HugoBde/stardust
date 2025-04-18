package main

import (
	"log"
	"net/http"
	"os"

	"github.com/fsnotify/fsnotify"
	"github.com/gorilla/websocket"
)

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

	err = watcher.Add("./shaders/")
	if err != nil {
		log.Fatal("Failed to start monitoring shaders folder")
	}

	http.Handle("/static/", http.StripPrefix("/static/", http.FileServer(http.Dir("./static"))))
	http.HandleFunc("/", homeHandler)
	http.HandleFunc("/ws", websocketHandler(watcher))
	log.Println("Listening on 8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}

func websocketHandler(watcher *fsnotify.Watcher) http.HandlerFunc {
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
		}

		go websocketRun(conn, watcher)
	}
}

func websocketRun(conn *websocket.Conn, watcher *fsnotify.Watcher) {
	defer conn.Close()

	files, err := os.ReadDir("./shaders")

	if err != nil {
		msg := WSError{Error: err.Error()}
		conn.WriteJSON(msg)
		return
	}

	for _, file := range files {
		shader, err := os.ReadFile("./shaders/" + file.Name())

		if err != nil {
			msg := WSError{
				Error: err.Error(),
			}
			conn.WriteJSON(msg)
			continue
		}

		msg := WSMessage{
			Name:   file.Name(),
			Shader: string(shader),
		}

		conn.WriteJSON(msg)
	}

	for {
		select {
		case evt := <-watcher.Events:
			switch evt.Op {
			case fsnotify.Write:
				log.Printf("%s updated. Broadcasting new content...", evt.Name)
				shader, err := os.ReadFile(evt.Name)
				if err != nil {
					msg := WSError{
						Error: err.Error(),
					}
					conn.WriteJSON(msg)
				}
				msg := WSMessage{
					Name:   evt.Name,
					Shader: string(shader),
				}
				conn.WriteJSON(msg)
			}

		}
	}
}

func homeHandler(w http.ResponseWriter, r *http.Request) {
	http.ServeFile(w, r, "./index.html")
}
