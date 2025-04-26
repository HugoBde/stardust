const std = @import("std");
const math = @import("math.zig");
const Vec3 = math.Vec3;
const Mat4 = math.Mat4;

pub const UP = math.Vec3{ .v = [3]f32{ 0.0, 1.0, 0.0 } };

pub var camera = Vec3{
    .v = [3]f32{ 0.0, 0.0, 2.0 },
};

pub fn moveUp() void {
    const camera_right = UP.cross_product(camera);
    const camera_up = camera.cross_product(camera_right).norm();
    camera = camera.add(camera_up.scale(0.1));
}

pub fn moveDown() void {
    const camera_right = UP.cross_product(camera);
    const camera_up = camera.cross_product(camera_right).norm();
    camera = camera.add(camera_up.scale(-0.1));
}

pub fn moveLeft() void {
    const camera_right = UP.cross_product(camera).norm();
    camera = camera.add(camera_right.scale(-0.1));
}

pub fn moveRight() void {
    const camera_right = UP.cross_product(camera).norm();
    camera = camera.add(camera_right.scale(0.1));
}

pub fn moveForward() void {
    camera = camera.add(camera.norm().scale(0.01));
}

pub fn moveBackward() void {
    camera = camera.add(camera.norm().scale(-0.01));
}

pub fn lookAt() Mat4 {
    const camera_right = UP.cross_product(camera).norm();
    const camera_up = camera.cross_product(camera_right).norm();

    const a = Mat4{
        .m = [4][4]f32{
            [4]f32{ camera_right.v[0], camera_right.v[1], camera_right.v[2], 0.0 },
            [4]f32{ camera_up.v[0], camera_up.v[1], camera_up.v[2], 0.0 },
            [4]f32{ camera.v[0], camera.v[1], camera.v[2], 0.0 },
            [4]f32{ 0.0, 0.0, 0.0, 1.0 },
        },
    };
    const b = Mat4.translate(-camera.v[0], -camera.v[1], -camera.v[2]);
    return a.mul(b);
}
