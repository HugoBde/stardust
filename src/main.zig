const std = @import("std");
const glfw = @import("c.zig").glfw;
const glew = @import("c.zig").glew;

const InitError = error{
    Glew,
    Glfw,
    WindowCreate,
};

pub fn main() !void {
    const window = try init();
    defer cleanup();

    // Loop
    while (glfw.glfwWindowShouldClose(window) == 0) {
        processInput(window);

        render();

        glfw.glfwSwapBuffers(window);
    }
}

fn init() !*glfw.GLFWwindow {
    //Init GLFW
    if (glfw.glfwInit() != glfw.GLFW_TRUE) {
        return InitError.Glfw;
    }

    //Create window
    glfw.glfwWindowHint(glfw.GLFW_RESIZABLE, @intFromBool(false));
    const window = glfw.glfwCreateWindow(800, 600, "stardust", null, null) orelse return InitError.WindowCreate;

    // Make window our current context
    glfw.glfwMakeContextCurrent(window);

    // Init OpenGL
    if (glew.glewInit() != glew.GLEW_OK) {
        return InitError.Glew;
    }

    glew.glViewport(0, 0, 800, 600);

    return window;
}

fn cleanup() void {
    glfw.glfwTerminate();
}

fn processInput(window: *glfw.GLFWwindow) void {
    glfw.glfwPollEvents();

    if (glfw.glfwGetKey(window, glfw.GLFW_KEY_ESCAPE) == glfw.GLFW_PRESS) {
        glfw.glfwSetWindowShouldClose(window, @intFromBool(true));
    }
}

fn render() void {
    glew.glClearColor(0.2, 0.3, 0.3, 1.0);
    glew.glClear(glew.GL_COLOR_BUFFER_BIT);
}
