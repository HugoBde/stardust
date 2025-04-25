const std = @import("std");

pub const Vec3 = struct {
    v: [3]f32,

    pub fn add(a: Vec3, b: Vec3) Vec3 {
        return Vec3{ .v = [3]f32{
            a.v[0] + b.v[0],
            a.v[1] + b.v[1],
            a.v[2] + b.v[2],
        } };
    }

    pub fn scale(a: Vec3, s: f32) Vec3 {
        return Vec3{ .v = [3]f32{
            a.v[0] * s,
            a.v[1] * s,
            a.v[2] * s,
        } };
    }

    fn magn(a: Vec3) f32 {
        return std.math.sqrt(a.v[0] * a.v[0] + a.v[1] * a.v[1] + a.v[2] * a.v[2]);
    }

    pub fn norm(a: Vec3) Vec3 {
        const m = magn(a);
        return Vec3{ .v = [3]f32{
            a.v[0] / m,
            a.v[1] / m,
            a.v[2] / m,
        } };
    }

    pub fn cross_product(a: Vec3, b: Vec3) Vec3 {
        return Vec3{ .v = [3]f32{
            a.v[1] * b.v[2] - a.v[2] * b.v[1],
            a.v[2] * b.v[0] - a.v[0] * b.v[2],
            a.v[0] * b.v[1] - a.v[1] * b.v[2],
        } };
    }
};

test "cross_product" {
    const a = Vec3{ .v = [3]f32{ 1.0, 0.0, -1.0 } };

    const b = Vec3{ .v = [3]f32{ 2.0, 3.0, -1.0 } };

    const axb = a.cross_product(b);

    const expected = Vec3{ .v = [3]f32{ 3.0, -1.0, 3.0 } };

    try std.testing.expectEqual(expected, axb);
}
