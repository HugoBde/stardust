const std = @import("std");
const math = std.math;
const sin = math.sin;
const cos = math.cos;

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

    fn magn(self: *const Vec3) f32 {
        return std.math.sqrt(self.v[0] * self.v[0] + self.v[1] * self.v[1] + self.v[2] * self.v[2]);
    }

    pub fn norm(self: *const Vec3) Vec3 {
        const m = magn(self);
        return Vec3{ .v = [3]f32{
            self.v[0] / m,
            self.v[1] / m,
            self.v[2] / m,
        } };
    }

    pub fn cross_product(self: *const Vec3, b: Vec3) Vec3 {
        return Vec3{ .v = [3]f32{
            self.v[1] * b.v[2] - self.v[2] * b.v[1],
            self.v[2] * b.v[0] - self.v[0] * b.v[2],
            self.v[0] * b.v[1] - self.v[1] * b.v[0],
        } };
    }

    pub fn format(
        self: Vec3,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;

        try writer.print("| {d:>6.2} {d:>6.2} {d:>6.2} |\n", .{
            self.v[0],
            self.v[1],
            self.v[2],
        });
    }
};

test "cross_product" {
    const a = Vec3{ .v = [3]f32{ 1.0, 0.0, -1.0 } };

    const b = Vec3{ .v = [3]f32{ 2.0, 3.0, -1.0 } };

    const axb = a.cross_product(b);

    const expected = Vec3{ .v = [3]f32{ 3.0, -1.0, 3.0 } };

    try std.testing.expectEqual(expected, axb);
}

pub const Mat4 = struct {
    m: [4][4]f32,

    pub const identity = Mat4{
        .m = [4][4]f32{
            [4]f32{ 1.0, 0.0, 0.0, 0.0 },
            [4]f32{ 0.0, 1.0, 0.0, 0.0 },
            [4]f32{ 0.0, 0.0, 1.0, 0.0 },
            [4]f32{ 0.0, 0.0, 0.0, 1.0 },
        },
    };

    pub fn rotation_x(angle: f32) Mat4 {
        return Mat4{
            .m = [4][4]f32{
                [4]f32{ 1.0, 0.0, 0.0, 0.0 },
                [4]f32{ 0, -sin(angle), cos(angle), 0.0 },
                [4]f32{ 0, cos(angle), sin(angle), 0.0 },
                [4]f32{ 0, 0.0, 0.0, 1.0 },
            },
        };
    }

    pub fn rotation_y(angle: f32) Mat4 {
        return Mat4{
            .m = [4][4]f32{
                [4]f32{ cos(angle), 0.0, sin(angle), 0.0 },
                [4]f32{ 0.0, 1.0, 0.0, 0.0 },
                [4]f32{ -sin(angle), 0.0, cos(angle), 0.0 },
                [4]f32{ 0.0, 0.0, 0.0, 1.0 },
            },
        };
    }

    pub fn rotation_z(angle: f32) Mat4 {
        return Mat4{
            .m = [4][4]f32{
                [4]f32{ cos(angle), -sin(angle), 0.0, 0.0 },
                [4]f32{ sin(angle), cos(angle), 0.0, 0.0 },
                [4]f32{ 0.0, 0.0, 1.0, 0.0 },
                [4]f32{ 0.0, 0.0, 0.0, 1.0 },
            },
        };
    }

    pub fn translate(x: f32, y: f32, z: f32) Mat4 {
        return Mat4{
            .m = [4][4]f32{
                [4]f32{ 1.0, 0.0, 0.0, x },
                [4]f32{ 0.0, 1.0, 0.0, y },
                [4]f32{ 0.0, 0.0, 1.0, z },
                [4]f32{ 0.0, 0.0, 0.0, 1.0 },
            },
        };
    }

    pub fn scale(x: f32, y: f32, z: f32) Mat4 {
        return Mat4{
            .m = [4][4]f32{
                [4]f32{ x, 0.0, 0.0, 0.0 },
                [4]f32{ 0.0, y, 0.0, 0.0 },
                [4]f32{ 0.0, 0.0, z, 0.0 },
                [4]f32{ 0.0, 0.0, 0.0, 1.0 },
            },
        };
    }

    pub fn projection_matrix(aspect_ratio: f32, fov: f32, z_near: f32, z_far: f32) Mat4 {
        const tan = math.tan(fov / 2);
        return Mat4{
            .m = [4][4]f32{
                [4]f32{ 1.0 / (aspect_ratio * tan), 0.0, 0.0, 0.0 },
                [4]f32{ 0.0, 1.0 / tan, 0.0, 0.0 },
                [4]f32{ 0.0, 0.0, -(z_far + z_near) / (z_far - z_near), -2.0 * z_far * z_near / (z_far - z_near) },
                [4]f32{ 0.0, 0.0, -1.0, 0.0 },
            },
        };
    }

    pub fn transpose(self: *Mat4) Mat4 {
        return Mat4{
            .m = [4][4]f32{
                [4]f32{ self.m[0], self.m[4], self.m[8], self.m[12] },
                [4]f32{ self.m[1], self.m[5], self.m[9], self.m[13] },
                [4]f32{ self.m[2], self.m[6], self.m[10], self.m[14] },
                [4]f32{ self.m[3], self.m[7], self.m[11], self.m[15] },
            },
        };
    }

    pub fn mul(self: *const Mat4, b: Mat4) Mat4 {
        var output: Mat4 = undefined;

        // Yes this is O(n3), I don't give a fuck, it's a 4x4 matrix
        for (0..4) |r| {
            for (0..4) |c| {
                output.m[r][c] =
                    self.m[r][0] * b.m[0][c] +
                    self.m[r][1] * b.m[1][c] +
                    self.m[r][2] * b.m[2][c] +
                    self.m[r][3] * b.m[3][c];
            }
        }

        return output;
    }

    pub fn compose(matrices: []const Mat4) Mat4 {
        var mat = matrices[0];
        for (matrices[1..]) |other| {
            mat = mat.mul(other);
        }

        return mat;
    }

    pub fn vec_mul(self: *const Mat4, v: Vec3) Vec3 {
        const w = self.m[3][0] * v.v[0] +
            self.m[3][1] * v.v[1] +
            self.m[3][2] * v.v[2] +
            self.m[3][3] * 1.0;

        return Vec3{
            .v = [3]f32{
                (self.m[0][0] * v.v[0] + self.m[0][1] * v.v[1] + self.m[0][2] * v.v[2]) / w,
                (self.m[1][0] * v.v[0] + self.m[1][1] * v.v[1] + self.m[1][2] * v.v[2]) / w,
                (self.m[2][0] * v.v[0] + self.m[2][1] * v.v[1] + self.m[2][2] * v.v[2]) / w,
            },
        };
    }

    pub fn format(
        self: Mat4,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;

        for (0..4) |i| {
            try writer.print("| {d:>6.2} {d:>6.2} {d:>6.2} {d:>6.2} |\n", .{
                self.m[i][0],
                self.m[i][1],
                self.m[i][2],
                self.m[i][3],
            });
        }
    }
};

test "matmul" {
    const a = Mat4{
        .m = [4][4]f32{
            [4]f32{ 1.0, 2.0, 3.0, 4.0 },
            [4]f32{ 4.0, 3.0, 2.0, 1.0 },
            [4]f32{ 0.0, 1.0, 0.0, 1.0 },
            [4]f32{ 0.0, 0.0, 1.0, 1.0 },
        },
    };
    const b = Mat4{
        .m = [4][4]f32{
            [4]f32{ 5.0, 6.0, 3.0, 4.0 },
            [4]f32{ 4.0, 3.0, 6.0, 5.0 },
            [4]f32{ 0.0, 5.0, 0.0, 5.0 },
            [4]f32{ 0.0, 0.0, 5.0, 5.0 },
        },
    };
    const axb = a.mul(b);
    const expected = Mat4{
        .m = [4][4]f32{
            [4]f32{ 13.0, 27.0, 35.0, 49.0 },
            [4]f32{ 32.0, 43.0, 35.0, 46.0 },
            [4]f32{ 4.0, 3.0, 11.0, 10.0 },
            [4]f32{ 0.0, 5.0, 5.0, 10.0 },
        },
    };
    try std.testing.expectEqual(expected, axb);
}

test "compose" {
    const result = Mat4.compose(&[_]Mat4{
        Mat4{
            .m = [4][4]f32{
                [4]f32{ 1.0, 2.0, 3.0, 4.0 },
                [4]f32{ 4.0, 3.0, 2.0, 1.0 },
                [4]f32{ 0.0, 1.0, 0.0, 1.0 },
                [4]f32{ 0.0, 0.0, 1.0, 1.0 },
            },
        },
        Mat4{
            .m = [4][4]f32{
                [4]f32{ 5.0, 6.0, 3.0, 4.0 },
                [4]f32{ 4.0, 3.0, 6.0, 5.0 },
                [4]f32{ 0.0, 5.0, 0.0, 5.0 },
                [4]f32{ 0.0, 0.0, 5.0, 5.0 },
            },
        },
        Mat4{
            .m = [4][4]f32{
                [4]f32{ -1.0, 0.0, 0.0, 0.0 },
                [4]f32{ 0.0, 2.0, 0.0, 0.0 },
                [4]f32{ 3.0, 0.0, 4.0, 0.0 },
                [4]f32{ 0.0, 0.0, 0.0, 5.0 },
            },
        },
    });
    const expected = Mat4{
        .m = [4][4]f32{
            [4]f32{ 92.0, 54.0, 140.0, 245.0 },
            [4]f32{ 73.0, 86.0, 140.0, 230.0 },
            [4]f32{ 29.0, 6.0, 44.0, 50.0 },
            [4]f32{ 15.0, 10.0, 20.0, 50.0 },
        },
    };
    try std.testing.expectEqual(expected, result);
}
