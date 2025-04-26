const std = @import("std");

const glfw = @import("c.zig").glfw;
const zgl = @import("zgl");

const shaders = @import("shaders.zig");
const STATE = @import("state.zig");
const camera = @import("camera.zig");

const math = @import("math.zig");
const Vec3 = math.Vec3;
const Mat4 = math.Mat4;

pub fn main() !void {
    const window = try init();
    defer cleanup();

    const vertices = [_]Vec3{
        Vec3{ .v = [3]f32{ -1.0, -1.0, -0.0 } },
        Vec3{ .v = [3]f32{ 1.0, -1.0, -0.0 } },
        Vec3{ .v = [3]f32{ 1.0, 1.0, -0.0 } },
        Vec3{ .v = [3]f32{ -1.0, 1.0, -0.0 } },
    };

    const indices = [_]u32{
        0, 1, 2,
        0, 2, 3,
    };

    // Create VAO
    const vertex_array = zgl.createVertexArray();

    // Create VBO
    const vertex_buffer = zgl.createBuffer();
    defer vertex_buffer.delete();

    // Create EBO
    const element_buffer = zgl.createBuffer();
    defer element_buffer.delete();

    // Buffer data in VBO
    vertex_buffer.storage(Vec3, vertices.len, &vertices, zgl.BufferStorageFlags{});

    // Buffer data in EBO
    element_buffer.storage(u32, indices.len, &indices, zgl.BufferStorageFlags{});

    vertex_array.vertexBuffer(0, vertex_buffer, 0, @sizeOf(Vec3));
    vertex_array.elementBuffer(element_buffer);

    vertex_array.enableVertexAttribute(0);
    vertex_array.attribFormat(0, 3, zgl.Type.float, false, 0);
    vertex_array.attribBinding(0, 0);

    const program_info = try shaders.createProgram();

    // Loop
    while (glfw.glfwWindowShouldClose(window) == 0) {
        glfw.glfwPollEvents();

        STATE.t += 0.01;

        STATE.render(program_info, vertex_array);

        glfw.glfwSwapBuffers(window);
    }
}

fn getProcAddress(comptime _: type, proc: [:0]const u8) ?zgl.binding.FunctionPointer {
    return glfw.glfwGetProcAddress(proc);
}

fn init() !*glfw.GLFWwindow {
    //Init GLFW
    if (glfw.glfwInit() != glfw.GLFW_TRUE) {
        return InitError.Glfw;
    }

    //Create window
    glfw.glfwWindowHint(glfw.GLFW_RESIZABLE, @intFromBool(false));
    const window = glfw.glfwCreateWindow(800, 600, "stardust", null, null) orelse return InitError.WindowCreate;

    _ = glfw.glfwSetCursorPosCallback(window, STATE.cursorPositionCallback);
    _ = glfw.glfwSetCursorEnterCallback(window, STATE.cursorEnterLeaveCallback);

    // Make window our current context
    glfw.glfwMakeContextCurrent(window);

    _ = glfw.glfwSetKeyCallback(window, keyCallback);

    try zgl.loadExtensions(void, getProcAddress);

    zgl.viewport(0, 0, 800, 600);

    return window;
}

fn cleanup() void {
    glfw.glfwTerminate();
}

fn keyCallback(window: ?*glfw.GLFWwindow, key: c_int, _: c_int, action: c_int, _: c_int) callconv(.C) void {
    if (action == glfw.GLFW_RELEASE) {
        return;
    }

    switch (key) {
        glfw.GLFW_KEY_K => camera.moveForward(),
        glfw.GLFW_KEY_H => camera.moveLeft(),
        glfw.GLFW_KEY_L => camera.moveRight(),
        glfw.GLFW_KEY_J => camera.moveBackward(),
        glfw.GLFW_KEY_SPACE => camera.moveUp(),
        glfw.GLFW_KEY_V => camera.moveDown(),
        glfw.GLFW_KEY_ESCAPE => glfw.glfwSetWindowShouldClose(window, @intFromBool(true)),
        else => {},
    }
}

const InitError = error{
    Glew,
    Glfw,
    WindowCreate,
};
