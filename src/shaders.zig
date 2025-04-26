const std = @import("std");
const zgl = @import("zgl");
const allocators = @import("allocators.zig");

pub fn createProgram() !ProgramInfo {
    var buffer: [10_000]u8 = undefined;
    var allocator = std.heap.FixedBufferAllocator.init(&buffer);

    const vertex_shader = try createShader("shaders/vertex.glsl", zgl.ShaderType.vertex, allocator.allocator());
    defer vertex_shader.delete();
    const fragment_shader = try createShader("shaders/fragment.glsl", zgl.ShaderType.fragment, allocator.allocator());
    defer fragment_shader.delete();

    const program = zgl.createProgram();
    program.attach(vertex_shader);
    program.attach(fragment_shader);
    program.link();

    if (program.get(zgl.ProgramParameter.link_status) == zgl.binding.FALSE) {
        const info_log = try program.getCompileLog(allocator.allocator());
        std.debug.print("{s}", .{info_log});
        return ShaderError.Compile;
    }

    var program_info = ProgramInfo{
        .program = program,
        .uniforms = std.StringHashMap(?u32).init(allocators.GPA.allocator()),
    };

    try program_info.uniforms.put("t", zgl.getUniformLocation(program, "t"));
    try program_info.uniforms.put("mouse_coord", zgl.getUniformLocation(program, "mouse_coord"));
    try program_info.uniforms.put("view", zgl.getUniformLocation(program, "view"));
    try program_info.uniforms.put("proj", zgl.getUniformLocation(program, "proj"));
    // try program_info.uniforms.put("camera", try (zgl.getUniformLocation(program, "camera") orelse error.Uniform));
    // try program_info.uniforms.put("camera_dir", try (zgl.getUniformLocation(program, "camera_dir") orelse error.Uniform));

    return program_info;
}

fn createShader(filename: []const u8, shader_type: zgl.ShaderType, allocator: std.mem.Allocator) !zgl.Shader {
    const file = try std.fs.cwd().openFile(filename, .{});
    const file_size = try file.getEndPos();
    const source = try file.reader().readAllAlloc(allocator, file_size);

    const shader = zgl.createShader(shader_type);
    errdefer shader.delete();
    shader.source(1, &[1][]u8{source});

    shader.compile();

    if (shader.get(zgl.ShaderParameter.compile_status) == zgl.binding.FALSE) {
        const info_log = try shader.getCompileLog(allocator);
        std.debug.print("{s}", .{info_log});
        return ShaderError.Compile;
    }

    return shader;
}

pub const ProgramInfo = struct {
    program: zgl.Program,
    uniforms: std.StringHashMap(?u32),
};

const ShaderError = error{Compile};
