//
//  main.swift
//  
//
//  Created by David Green on 4/14/20.
//

import SwiftCocoaWindowing
import OpenGL.GL3

func checkOpenGLErrors() {
    var error = glGetError()
    while error != 0 {
        print("OpenGL Error: \(error)")
        error = glGetError()
    }
}

func compileShader(type: GLenum, source: String) -> GLuint {
    var mutableSource = source
    let shader = glCreateShader(type); checkOpenGLErrors()
    mutableSource.withUTF8 { (src) in
        var glCharPointer = UnsafeRawPointer(src.baseAddress)?.bindMemory(to: GLchar.self, capacity: 1)
        glShaderSource(shader, 1, &glCharPointer, nil); checkOpenGLErrors()
    }
    glCompileShader(shader); checkOpenGLErrors()
    
    var result: GLint = 0
    glGetShaderiv(shader, GLenum(GL_COMPILE_STATUS), &result); checkOpenGLErrors()
    
    if result == GL_FALSE {
        var length: GLint = 0
        glGetShaderiv(shader, GLenum(GL_INFO_LOG_LENGTH), &length); checkOpenGLErrors()
        let message: UnsafeMutablePointer<GLchar>? =  UnsafeMutablePointer<GLchar>.allocate(capacity: Int(length))
        glGetShaderInfoLog(shader, length, &length, message); checkOpenGLErrors()
        let messagePointer = UnsafeRawPointer(message!).bindMemory(to: CChar.self, capacity: 1)
        print("Shader failed to compile:")
        print("\(String(cString: messagePointer))")
    }
    
    return shader
}

func loadShader(vertexShader: String, fragmentShader: String) -> GLuint {
    let program = glCreateProgram()
    let vs = compileShader(type: GLenum(GL_VERTEX_SHADER), source: vertexShader)
    let fs = compileShader(type: GLenum(GL_FRAGMENT_SHADER), source: fragmentShader)
    
    glAttachShader(program, vs); checkOpenGLErrors()
    glAttachShader(program, fs); checkOpenGLErrors()
    glLinkProgram(program); checkOpenGLErrors()
    glValidateProgram(program); checkOpenGLErrors()
    glDetachShader(program, vs); checkOpenGLErrors()
    glDetachShader(program, fs); checkOpenGLErrors()
    
    glDeleteShader(vs); checkOpenGLErrors()
    glDeleteShader(fs); checkOpenGLErrors()
    
    return program
}

initApplication()
createWindow(title: "Cocoa Window", width: 640, height: 480)

setWindowBackgroundColor(r: 0.2, g: 0.2, b: 0.2, a: 0.7)
setWindowBackgroundEnableSRGB(enable: true)
setWindowTitleBarHidden(hidden: true)
setWindowTitleHidden(hidden: true)
setWindowTransparency(transparent: true)


print("OpenGL Vendor: \(String(cString: glGetString(GLenum(GL_VENDOR))))")
print("OpenGL Renderer: \(String(cString: glGetString(GLenum(GL_RENDERER))))")
print("OpenGL Version: \(String(cString: glGetString(GLenum(GL_VERSION))))")
print("OpenGL Shading Language: \(String(cString: glGetString(GLenum(GL_SHADING_LANGUAGE_VERSION))))")

glEnable(GLenum(GL_FRAMEBUFFER_SRGB)); checkOpenGLErrors()
glClearColor(0.1, 0.1, 0.1, 0.7); checkOpenGLErrors()

let shader = loadShader(vertexShader: """
#version 330 core

layout(location = 0) in vec4 position;

void main ()
{
    gl_Position = position;
}
""",
                        fragmentShader: """
#version 330 core

out vec4 color;

void main ()
{
    color = vec4( 1.0, 0.0, 0.0, 1.0 );
}
""")

glUseProgram(shader); checkOpenGLErrors()

let positions: [Float] = [
    -0.5, -0.5,
    0.5, -0.5,
    0.0, 0.5
]

var vao: GLuint = 0
glGenVertexArrays(1, &vao); checkOpenGLErrors()
glBindVertexArray(vao); checkOpenGLErrors()

var vbo: GLuint = 0
glGenBuffers(1, &vbo); checkOpenGLErrors()
glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo); checkOpenGLErrors()
glBufferData(GLenum(GL_ARRAY_BUFFER), 6 * MemoryLayout<Float>.size, positions, GLenum(GL_STATIC_DRAW)); checkOpenGLErrors()

glEnableVertexAttribArray(0); checkOpenGLErrors()
glVertexAttribPointer(0, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<Float>.size * 2), nil); checkOpenGLErrors()

    
while !getWindowIsClosing() {
    processWindowEvents()
    
    if getKeyDown(keyCode: .F) { setWindowFullscreen(fullscreen: true) }
    if getKeyDown(keyCode: .G) { setWindowFullscreen(fullscreen: false) }
    if getKeyDown(keyCode: .R) { setWindowSize(width: 1280, height: 720) }
    if getKeyDown(keyCode: .E) { setWindowSize(width: 640, height: 480) }
    if getKeyDown(keyCode: .Q) && getModifierKey(keyCode: .Command) { closeApplication() }
    
    glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)); checkOpenGLErrors()
    glDrawArrays(GLenum(GL_TRIANGLES), 0, 3); checkOpenGLErrors()
    
    refreshWindow()
}

closeWindow()
closeApplication()
