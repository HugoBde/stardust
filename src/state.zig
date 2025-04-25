const std = @import("std");
const glfw = @import("c.zig").glfw;
const zgl = @import("zgl");
const shaders = @import("shaders.zig");
const camera = @import("camera.zig");

const self = @This();

pub var t: f32 = 0.0;
pub var mouse_x: f32 = 0.0;
pub var mouse_y: f32 = 0.0;

pub fn cursorPositionCallback(_: ?*glfw.GLFWwindow, x: f64, y: f64) callconv(.C) void {
    mouse_x = @floatCast(x);
    mouse_y = @floatCast(y);
}

pub fn cursorEnterLeaveCallback(_: ?*glfw.GLFWwindow, entered: c_int) callconv(.C) void {
    if (entered == 0) {
        mouse_x = 0.0;
        mouse_y = 0.0;
    }
}

pub fn render(program_info: shaders.ProgramInfo, vertex_array: zgl.VertexArray) void {
    zgl.clearColor(0.2, 0.3, 0.3, 1.0);
    zgl.clear(.{ .color = true });

    program_info.program.use();

    zgl.uniform1f(program_info.uniforms.get("t"), self.t);
    zgl.uniform2f(program_info.uniforms.get("mouse_coord"), self.mouse_x, self.mouse_y);

    zgl.uniform3f(program_info.uniforms.get("camera"), camera.camera.v[0], camera.camera.v[1], camera.camera.v[2]);
    zgl.uniform3f(program_info.uniforms.get("camera_dir"), camera.camera_dir.v[0], camera.camera_dir.v[1], camera.camera_dir.v[2]);

    vertex_array.bind();
    zgl.drawElements(zgl.PrimitiveType.triangles, 6, zgl.ElementType.unsigned_int, 0);
}
