const math = @import("math.zig");
const Vec3 = math.Vec3;

const VERTICAL = math.Vec3{ .v = [3]f32{ 0.0, 1.0, 0.0 } };

pub var camera = math.Vec3{
    .v = [3]f32{ 0.0, 0.0, -3.0 },
};

pub var camera_dir = math.Vec3{
    .v = [3]f32{ 0.0, 0.0, 1.0 },
};

pub fn cameraUp() void {
    camera.v[1] += 0.01;
}

pub fn cameraDown() void {
    camera.v[1] -= 0.01;
}

pub fn cameraLeft() void {
    const dir = VERTICAL.cross_product(camera).norm();
    camera = camera.add(dir.scale(0.01));
}

pub fn cameraRight() void {
    const dir = VERTICAL.cross_product(camera).norm();
    camera = camera.add(dir.scale(-0.01));
}

pub fn cameraForward() void {
    var dir = camera_dir;
    dir.y = 0.0;
    dir = dir.norm();
    camera = camera.add(dir.scale(0.01));
}

pub fn cameraBackward() void {
    var dir = camera_dir;
    dir.y = 0.0;
    dir = dir.norm();
    camera = camera.add(dir.scale(-0.01));
}
