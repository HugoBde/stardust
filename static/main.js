let t = 0;

let buffers = null;
let program_info = null;

let vertex_source = `#version 300 es
    in vec4 aVertexPosition;
    out vec2 fragCoord;
    void main() {
      gl_Position = aVertexPosition;
      fragCoord = aVertexPosition.xy;
    }
  `;

let fragment_source = `#version 300 es
    precision mediump float;
    in vec2  fragCoord;
    out vec4 fragColor;
    uniform float t;
    void main() {
      fragColor  = vec4(fragCoord.x / 2.0 + 0.5, fragCoord.y / 2.0 + 0.5, sin(t * 10.) / 2.0 + 0.5, 1.0);
    }
  `;

function main() {
  const gl = init_gl();

  if (gl === null) {
    console.log("Failed to get gl context");
    return;
  }

  program_info = init_shader_program(gl, vertex_source, fragment_source);

  if (program_info === null) {
    console.log("Failed to compile program");
    return;
  }

  buffers = init_buffers(gl);

  render(gl, buffers, program_info);

  const ws = new WebSocket("/ws")

  ws.onmessage = (msg) => {
    let data = JSON.parse(msg.data);

    if (data.error) {
      console.log(data.error);
      return;
    }

    if (data.name.includes("vertex")) {
      vertex_source = data.shader;
    } else if (data.name.includes("fragment")) {
      fragment_source = data.shader;
    }

    program_info = init_shader_program(gl, vertex_source, fragment_source);

    if (program_info === null) {
      console.log("Failed to compile program");
      return;
    }

    buffers = init_buffers(gl);

    t = 0
  }
}

/**
  * @returns {WebGLRenderingContext | null}
  */
function init_gl() {
  const canvas = document.getElementById("canvas");
  return canvas.getContext("webgl2");
}

/**
  * @param {WebGLRenderingContext} gl
  * @returns {{positions: WebGLBuffer}}
  */
function init_buffers(gl) {
  const position_buffer = gl.createBuffer();
  gl.bindBuffer(gl.ARRAY_BUFFER, position_buffer);
  const positions = [1.0, 1.0, -1.0, 1.0, 1.0, -1.0, -1.0, -1.0];
  gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(positions), gl.STATIC_DRAW);

  return {
    positions: position_buffer
  };
}

/**
  * @param {WebGLRenderingContext} gl
  * @returns void
  */
function clear(gl) {
  gl.clearColor(0.0, 0.0, 0.0, 1.0);
  gl.clear(gl.COLOR_BUFFER_BIT);
}

/**
  * @param {WebGLRenderingContext} gl
  * @param {{positions: WebGLBuffer}} buffers
  * @param {{program: WebGLProgram, attrib_locations: {name: string, location: GLuint}[], uniform_locations: {name: string, location:number}[]}} program_info
  * @returns void
  */
function render(gl) {
  clear(gl);

  setPositionAttribute(gl, buffers, program_info);

  // Tell WebGL to use our program when drawing
  gl.useProgram(program_info.program);

  t += 0.01;
  gl.uniform1f(program_info.uniform_locations[0].location, t)

  {
    const offset = 0;
    const vertex_count = 4;
    gl.drawArrays(gl.TRIANGLE_STRIP, offset, vertex_count);
  }

  requestAnimationFrame(() => render(gl, buffers, program_info));
}

/**
  * @param {WebGLRenderingContext} gl
  * @param {{positions: WebGLBuffer}} buffers
  * @param {{program: WebGLProgram, attrib_locations: {name: string, location: GLuint}[], uniform_locations: {name: string, location:number}[]}} program_info
  * @returns void
  */
function setPositionAttribute(gl, buffers, program_info) {
  const numComponents = 2; // pull out 2 values per iteration
  const type = gl.FLOAT; // the data in the buffer is 32bit floats
  const normalize = false; // don't normalize
  const stride = 0; // how many bytes to get from one set of values to the next
  const offset = 0; // how many bytes inside the buffer to start from
  gl.bindBuffer(gl.ARRAY_BUFFER, buffers.positions);
  gl.vertexAttribPointer(
    program_info.attrib_locations[0].location,
    numComponents,
    type,
    normalize,
    stride,
    offset,
  );
  gl.enableVertexAttribArray(program_info.attrib_locations[0].location);
}

/**
  * @param {WebGLRenderingContext} gl
  * @returns {{program: WebGLProgram, attrib_locations: {name: string, location: GLuint}[], uniform_locations: {name: string, location:number}[]} | null}
  */
function init_shader_program(gl, vertex_source, fragment_source) {


  const vertex_shader = load_shader(gl, gl.VERTEX_SHADER, vertex_source);
  if (vertex_shader === null) {
    return null;
  }

  const fragment_shader = load_shader(gl, gl.FRAGMENT_SHADER, fragment_source);
  if (fragment_shader === null) {
    return null;
  }

  // Create the shader program

  const shader_program = gl.createProgram();
  gl.attachShader(shader_program, vertex_shader);
  gl.attachShader(shader_program, fragment_shader);
  gl.linkProgram(shader_program);

  // If creating the shader program failed, alert

  if (!gl.getProgramParameter(shader_program, gl.LINK_STATUS)) {
    alert(
      `Unable to initialize the shader program: ${gl.getProgramInfoLog(
        shader_program,
      )}`,
    );
    return null;
  }

  const program_info = {
    program: shader_program,
    attrib_locations: [
      { name: "vertex_position", location: gl.getAttribLocation(shader_program, "aVertexPosition") }
    ],
    uniform_locations: [
      { name: "t", location: gl.getUniformLocation(shader_program, "t") }
    ],
  };

  return program_info;
}

/**
  * @param {WebGLRenderingContext} gl
  * @param {GLenum} type
  * @param {string} source
  * @returns {WebGLShader}
  */
function load_shader(gl, type, source) {
  const shader = gl.createShader(type);

  gl.shaderSource(shader, source);

  gl.compileShader(shader);

  if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
    console.log(
      `An error occurred compiling the shaders: ${gl.getShaderInfoLog(shader)}`,
    );
    gl.deleteShader(shader);
    return null;
  }

  return shader;
}

main();
