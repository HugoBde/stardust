const std = @import("std");

const glfw = @import("c.zig").glfw;
const zgl = @import("zgl");

const shaders = @import("shaders.zig");
const camera = @import("camera.zig");
const Mat4 = @import("math.zig").Mat4;
const Vec3 = @import("math.zig").Vec3;

const self = @This();

pub var t: f32 = 0.0;
pub var mouse_x: f32 = 0.0;
pub var mouse_y: f32 = 0.0;
const proj = Mat4.projection_matrix(800.0 / 600.0, std.math.pi / 2.0, 0.1, 100.0);

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

    program_info.program.uniform1f(program_info.uniforms.get("t").?, self.t);
    program_info.program.uniform2f(program_info.uniforms.get("mouse_coord").?, self.mouse_x, self.mouse_y);

    const view = camera.lookAt();

    std.debug.print("{}\n\n", .{proj});
    std.debug.print("{}\n\n", .{view});

    program_info.program.uniformMatrix4(program_info.uniforms.get("proj").?, true, &.{proj.m});
    program_info.program.uniformMatrix4(program_info.uniforms.get("view").?, true, &.{view.m});

    vertex_array.bind();
    zgl.drawElements(zgl.PrimitiveType.triangles, 6, zgl.ElementType.unsigned_int, 0);
}
