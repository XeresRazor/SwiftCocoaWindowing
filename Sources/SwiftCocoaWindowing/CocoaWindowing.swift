//
//  CocoaWindowing.swift
//  
//
//  Created by David Green on 4/14/20.
//

import Cocoa

// MARK: Private classes

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationWillFinishLaunching(_ notification: Notification) {
        let menubar = NSMenu()
        let appMenuItem = NSMenuItem()
        menubar.addItem(appMenuItem)
        NSApp.mainMenu = menubar
        
        let appMenu = NSMenu()
        let appName = ProcessInfo.processInfo.processName
        let quitTitle = "Quit \(appName)"
        let quitMenuItem = NSMenuItem.init(title: quitTitle, action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        appMenu.addItem(quitMenuItem)
        appMenuItem.submenu = appMenu
        
        NSApp.setActivationPolicy(.regular)
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        _windowShouldClose = true
    }
}

class WindowDelegate: NSObject, NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        _windowShouldClose = true
        _windowCreated = false
    }
}

class OpenGLView: NSOpenGLView, NSTextInput {
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        becomeFirstResponder()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        becomeFirstResponder()
    }
    
    
    override func prepareOpenGL() {
        super.prepareOpenGL()
        guard let openGLContext = self.openGLContext else {
            return
        }
        openGLContext.makeCurrentContext()
    }
    
    override func draw(_ dirtyRect: NSRect) {
        NSColor.init(calibratedRed: 0, green: 0, blue: 0, alpha: 0).set()
        dirtyRect.fill()
    }
    
    override var acceptsFirstResponder: Bool {
        return true
    }
    
    override func keyDown(with event: NSEvent) {
        print("keyDown")
    }

    override func keyUp(with event: NSEvent) {
        print("keyUp")
    }
    
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        return true
    }
}

// Global vars
var _workingDirectory: String = ""
var _applicationInited: Bool = false

var _appDelegate: AppDelegate = AppDelegate()
var _windowDelegate: WindowDelegate = WindowDelegate()
var _window: NSWindow? = nil
var _glView: NSOpenGLView = NSOpenGLView()
var _windowCreated: Bool = false
var _windowShouldClose: Bool = true
var _windowFullscreen: Bool = false
var _sRGBEnabled: Bool = false

let kKeyCount = 132
let kMouseButtonCount = 3
let kModifierKeyCount = 4

var _activeKeys: [Bool] = [Bool](repeating: false, count: kKeyCount)
var _downKeys: [Bool] = [Bool](repeating: false, count: kKeyCount)
var _upKeys: [Bool] = [Bool](repeating: false, count: kKeyCount)
var _modifierActiveKeys: [Bool] = [Bool](repeating: false, count: kModifierKeyCount)
var _activeMouseButtons: [Bool] = [Bool](repeating: false, count: kMouseButtonCount)
var _downMouseButtons: [Bool] = [Bool](repeating: false, count: kMouseButtonCount)
var _upMouseButtons: [Bool] = [Bool](repeating: false, count: kMouseButtonCount)
var _mousePositionX: Float = 0
var _mousePositionY: Float = 0
var _mouseScrollValueX: Float = 0
var _mouseScrollValueY: Float = 0


public enum Key: Int {
    case A = 97
    case B = 98
    case C = 99
    case D = 100
    case E = 101
    case F = 102
    case G = 103
    case H = 104
    case I = 105
    case J = 106
    case K = 107
    case L = 108
    case M = 109
    case N = 110
    case O = 111
    case P = 112
    case Q = 113
    case R = 114
    case S = 115
    case T = 116
    case U = 117
    case V = 118
    case W = 119
    case X = 120
    case Y = 121
    case Z = 122
    
    case zero = 48
    case one = 49
    case two = 50
    case three = 51
    case four = 52
    case five = 53
    case six = 54
    case seven = 55
    case eight = 56
    case nine = 57
    
    case plus = 43
    case minus = 45
    case star = 42
    case equals = 61
    case underscore = 95
    case rightParentheses = 41
    case leftParentheses = 40
    case rightCurlyBrace = 125
    case leftCurlyBrace = 173
    case rightSquareBracket = 93
    case leftSquareBracket = 91
    case ampersand = 38
    case caret = 94
    case percent = 37
    case dollarsign = 36
    case pound = 35
    case at = 64
    case exclamationMark = 33
    case tilde = 126
    case semicolon = 59
    case colon = 58
    case singlequote = 39
    case doublequote = 34
    case backslash = 92
    case forwardslash = 47
    case questionMark = 63
    case comma = 44
    case period = 46
    case lessThan = 60
    case greaterThan = 62
    
    case enter = 13
    case tab = 9
    case delete = 127
    case up = 63232
    case down = 63233
    case left = 63234
    case right = 63235
}

public enum ModifierKey: Int {
    case Command = 0
    case Option = 1
    case Control = 2
    case Shift = 3
}

public enum MouseButton: Int {
    case left = 0
    case right = 1
}


// MARK: Application control
public func initApplication() {
    precondition(_applicationInited == false, "The application has already been initialized.")
    
    _applicationInited = true
    
    // Initialize the application
    _ = NSApplication.shared
    
    // Set the current working directory
    // If using an app bundle, set it to the resources folder
    let fileManager = FileManager.default
    var workingDirectory = fileManager.currentDirectoryPath
    
    let appBundlePath = "\(Bundle.main.bundlePath)/Contents/Resources"
    
    if fileManager.changeCurrentDirectoryPath(appBundlePath) {
        workingDirectory = appBundlePath
    }
    
    _workingDirectory = workingDirectory
    
    print("Working directory: \(_workingDirectory)")
    
    // Assign the application delegate
    NSApp.delegate = _appDelegate
    NSApp.finishLaunching()
}

public func closeApplication() {
    closeWindow()
    _applicationInited = false
}

// MARK: Basic window functions
public func createWindow(title: String, width: Int, height: Int) {
    precondition(_windowCreated == false, "A window has already been created.")
    
    _windowCreated = true
    _windowShouldClose = false
    
    // create the main window and the content view
    let windowWidth = CGFloat(width)
    let windowHeight = CGFloat(height)
    let screenRect = NSScreen.main!.visibleFrame
    let windowFrame = NSRect(x: (screenRect.size.width - windowWidth) * 0.5,
                             y: (screenRect.size.height - windowHeight) * 0.5,
                             width: windowWidth, height: windowHeight)
    
    let windowStyleMask: NSWindow.StyleMask = [ .closable, .titled, .miniaturizable, .resizable]
    
    _window = NSWindow(contentRect: windowFrame, styleMask: windowStyleMask, backing: .buffered, defer: false)
    guard let window = _window else { fatalError("Failed to create a window") }
    window.displaysWhenScreenProfileChanges = true
    window.delegate = _windowDelegate
    window.title = title
    window.makeKeyAndOrderFront(nil)
    
    let openGLAttributes: [UInt32] = [
        UInt32(NSOpenGLPFAOpenGLProfile), UInt32(NSOpenGLProfileVersion3_2Core),
        UInt32(NSOpenGLPFAAccelerated),
        UInt32(NSOpenGLPFADoubleBuffer),
        UInt32(NSOpenGLPFAColorSize), 24,
        UInt32(NSOpenGLPFAAlphaSize), 8,
        UInt32(NSOpenGLPFADepthSize), 24,
        0
    ]
    
    // Create a pixel format and gl context based off our chosen attributes
    guard let pixelFormat = NSOpenGLPixelFormat(attributes: openGLAttributes) else { fatalError("Couldn't get pixel format") }
    let openGLContext = NSOpenGLContext(format: pixelFormat, share: nil)
    
    // Set some properties for the windows main view
    guard let contentView = window.contentView else { fatalError("No content view") }
    contentView.autoresizingMask = [.width, .height]
    contentView.autoresizesSubviews = true
    
    // Create an openGL view
    _glView.pixelFormat = pixelFormat
    _glView.openGLContext = openGLContext
    _glView.frame = contentView.bounds
    _glView.autoresizingMask = [.width, .height]
    _glView.wantsBestResolutionOpenGLSurface = true
    _glView.openGLContext?.view = _glView
    // Add it as a subview
    contentView.addSubview(_glView)
    
    window.initialFirstResponder = _glView
    window.makeFirstResponder(_glView)
    
    _glView.openGLContext?.makeCurrentContext()
    
    // this enables(1) or disables(0) vsync
    var swapInterval: GLint = 1
    _glView.openGLContext?.setValues(&swapInterval, for: .swapInterval)
    
    // Default the background color to white
    window.backgroundColor = NSColor(red: 1, green: 1, blue: 1, alpha: 1)
}

public func closeWindow() {
    if _window == nil {
        return
    }
    _windowShouldClose = true
    _windowCreated = false
    
    _window!.close()
    _window = nil
}

public func processWindowEvents() {
    for k in 0 ..< kKeyCount {
        _downKeys[k] = false
        _upKeys[k] = false
    }
    
    for b in 0 ..< kMouseButtonCount {
        _downMouseButtons[b] = false
        _upMouseButtons[b] = false
    }
    
    var event: NSEvent? = nil
    
    repeat {
        event = NSApp.nextEvent(matching: .any, until: nil, inMode: .default, dequeue: true)
        
        guard let currentEvent = event else { continue   }
        
        switch currentEvent.type {
        case .keyDown:
            let modifierFlags = currentEvent.modifierFlags
            if modifierFlags.contains(.command) { _modifierActiveKeys[ModifierKey.Command.rawValue] = true }
            if modifierFlags.contains(.control) { _modifierActiveKeys[ModifierKey.Control.rawValue] = true }
            if modifierFlags.contains(.option) { _modifierActiveKeys[ModifierKey.Option.rawValue] = true }
            if modifierFlags.contains(.shift) { _modifierActiveKeys[ModifierKey.Shift.rawValue] = true }
            
            var c = Int(currentEvent.charactersIgnoringModifiers!.utf8CString[0])
            
            if c < kKeyCount {
                if c >= "A".utf8CString[0] && c <= "Z".utf8CString[0] { c += 32 }
                if c == 25 { c = Key.tab.rawValue }
                if !_activeKeys[c] { _downKeys[c] = true }
                _activeKeys[c] = true
            }
            
            if c >= Key.up.rawValue && c <= Key.right.rawValue {
                c -= 63104
                if !_activeKeys[c] { _downKeys[c] = true }
                _activeKeys[c] = true
            }
        case .keyUp:
            let modifierFlags = currentEvent.modifierFlags
            if modifierFlags.contains(.command) { _modifierActiveKeys[ModifierKey.Command.rawValue] = false }
            if modifierFlags.contains(.control) { _modifierActiveKeys[ModifierKey.Control.rawValue] = false }
            if modifierFlags.contains(.option) { _modifierActiveKeys[ModifierKey.Option.rawValue] = false }
            if modifierFlags.contains(.shift) { _modifierActiveKeys[ModifierKey.Shift.rawValue] = false }
            
            var c = Int(currentEvent.charactersIgnoringModifiers!.utf8CString[0])
            
            if c < kKeyCount {
                if c >= "A".utf8CString[0] && c <= "Z".utf8CString[0] { c += 32 }
                if c == 25 { c = Key.tab.rawValue }
                _activeKeys[c] = false
                _upKeys[c] = true
            }
            
            if c >= Key.up.rawValue && c <= Key.right.rawValue {
                c -= 63104
                _activeKeys[c] = false
                _upKeys[c] = true
            }
        case .scrollWheel:
            _mouseScrollValueY = Float(currentEvent.scrollingDeltaY)
            _mouseScrollValueX = Float(currentEvent.scrollingDeltaX)
        default:
            continue
        }
    } while event != nil
    
    // Mouse position
    let mouseLocationOnScreen = NSEvent.mouseLocation
    guard let window = _window else { fatalError("No window.") }
    var pointInWindow = NSPoint()
    if #available(OSX 10.12, *) {
        pointInWindow = window.convertPoint(fromScreen: mouseLocationOnScreen)
    } else {
        // Fallback on earlier versions
        let windowRect = window.convertFromScreen(NSRect(x: mouseLocationOnScreen.x, y: mouseLocationOnScreen.y, width: 1, height: 1))
        pointInWindow = windowRect.origin
        
    }
    let mouseLocationInView = _glView.convert(pointInWindow, from: nil)
    _mousePositionX = Float(mouseLocationInView.x)
    _mousePositionY = Float(_glView.frame.size.height - mouseLocationInView.y)
    
    let mouseButtonMask = NSEvent.pressedMouseButtons
    for m in 0 ..< kMouseButtonCount {
        if (mouseButtonMask & (1 << m)) != 0 {
            if !_activeMouseButtons[m]  { _downMouseButtons[m] = true }
            _activeMouseButtons[m] = true
        } else if (mouseButtonMask & (1 << m)) == 0 && _activeMouseButtons[m] {
            _activeMouseButtons[m] = false
            _upMouseButtons[m] = true
        }
    }
}

public func refreshWindow() {
    _glView.openGLContext?.flushBuffer()
}

// MARK: Window display settings
public func setCursorHidden(hidden: Bool) {
    if hidden {
        NSCursor.hide()
    } else {
        NSCursor.unhide()
    }
}

// This will move the window into a new fullscreen space or exit from one
public func setWindowFullscreen(fullscreen: Bool) {
    if fullscreen && !_windowFullscreen {
        _window?.toggleFullScreen(nil)
        _windowFullscreen = true
    } else if !fullscreen && _windowFullscreen {
        _window?.toggleFullScreen(nil)
        _windowFullscreen = false
    }
}

// This will make the OpenGLView enter complete fullscreen by making the NSView the full screen size and on top of everything else.
// App switching will not work while in fullscreen. Because of this setWindowFullscreen() is recommended instead.
public func setWindowCompleteFullscreen(completeFullscreen: Bool) {
    if completeFullscreen && !_glView.isInFullScreenMode {
        if !_glView.isInFullScreenMode {
            _glView.enterFullScreenMode((_window?.screen)!, withOptions: nil)
        }
    } else if !completeFullscreen && _glView.isInFullScreenMode {
        _glView.exitFullScreenMode(options: nil)
        _window?.makeKeyAndOrderFront(nil)
        
        // This is done to prevent keys from beeping
        _window?.initialFirstResponder = _glView
        _window?.makeFirstResponder(_glView)
    }
}

public func setWindowSize(width: Float, height: Float) {
    if !_windowFullscreen {
        guard let window = _window else { return }
        // Update the current frame
        
        
        let titlebarHeight = window.frame.size.height - window.contentView!.frame.size.height
        var frame = NSScreen.main!.visibleFrame
        frame.origin.x += (frame.size.width - CGFloat(width)) / 2
        frame.origin.y += (frame.size.height - CGFloat(height)) / 2
        frame.size.width = CGFloat(width)
        frame.size.height = CGFloat(height) + titlebarHeight
        window.setFrame(frame, display: true, animate: true)
        
    }
}

public func setWindowPosition(x: Float, y: Float) {
    if !_windowFullscreen {
        guard let window = _window else { return }
        var frame = window.frame
        frame.origin.x = CGFloat(x)
        frame.origin.y = CGFloat(y)
        window.setFrame(frame, display: true, animate: true)
    }
}

// MARK: Window background and chrome
public func setWindowBackgroundColor(r: Float, g: Float, b: Float, a: Float) {
    let tosRGB = {(v: Float) -> CGFloat in
        if v <= 0.0031308 { return CGFloat(v * 12.92) }
        else { return CGFloat(1.055 * pow(v, 1.0 / 2.4) - 0.055) }
    }
    
    if _sRGBEnabled {
        _window?.backgroundColor = NSColor(red: tosRGB(r), green: tosRGB(b), blue: tosRGB(b), alpha: CGFloat(a))
    } else {
        _window?.backgroundColor = NSColor(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: CGFloat(a))
    }
}

public func setWindowBackgroundEnableSRGB(enable: Bool) {
    _sRGBEnabled = enable
}

public func setWindowTitleBarHidden(hidden: Bool) {
    _window?.titlebarAppearsTransparent = hidden
}

public func setWindowTitleHidden(hidden: Bool) {
    _window?.titleVisibility = hidden ? .hidden : .visible
}

public func setWindowTransparency(transparent: Bool) {
    var transp: GLint = transparent ? 0 : 1
    _glView.openGLContext?.setValues(&transp, for: .surfaceOpacity)
    _window?.isOpaque = transparent ? false : true
}


// MARK: Keyboard
public func getKey(keyCode: Key) -> Bool {
    var key = keyCode.rawValue
    if key < kKeyCount {
        if key >= 65 && key <= 90 { key += 32 } // ignore caps case
        if key >= Key.up.rawValue && key <= Key.right.rawValue { key -= 63104 } // Fix for arrow keys
        return _activeKeys[key]
    }
    return false
}

public func getKeyDown(keyCode: Key) -> Bool {
    var key = keyCode.rawValue
    if key < kKeyCount {
        if key >= 65 && key <= 90 { key += 32 } // ignore caps case
        if key >= Key.up.rawValue && key <= Key.right.rawValue { key -= 63104 } // Fix for arrow keys
        return _downKeys[key]
    }
    return false
}

public func getKeyUp(keyCode: Key) -> Bool {
    var key = keyCode.rawValue
    if key < kKeyCount {
        if key >= 65 && key <= 90 { key += 32 } // ignore caps case
        if key >= Key.up.rawValue && key <= Key.right.rawValue { key -= 63104 } // Fix for arrow keys
        return _upKeys[key]
    }
    return false
}

public func getModifierKey(keyCode: ModifierKey) -> Bool {
    if keyCode.rawValue < kModifierKeyCount {
        return _modifierActiveKeys[keyCode.rawValue]
    }
    return false
}

// MARK: Mouse
public func getMouseButton(button: Int) -> Bool {
    if button < kMouseButtonCount {
        return _activeMouseButtons[button]
    }
    return false
}

public func getMouseButtonDown(button: Int) -> Bool {
    if button < kMouseButtonCount {
        return _downMouseButtons[button]
    }
    return false
}

public func getMouseButtonUp(button: Int) -> Bool {
    if button < kMouseButtonCount {
        return _upMouseButtons[button]
    }
    return false
}

public func getMousePosition() -> (x: Float, y: Float) {
    return (_mousePositionX, _mousePositionY)
}

public func getMousePositionX() -> Float {
    return _mousePositionX
}

public func getMousePositionY() -> Float {
    return _mousePositionY
}

public func getMouseScroll() -> (x: Float, y: Float) {
    return (_mouseScrollValueX, _mouseScrollValueY)
}

public func getMouseScrollX() -> Float {
    return _mouseScrollValueX
}

public func getMouseScrollY() -> Float {
    return _mouseScrollValueY
}

// MARK: Window properties
public func getWindowIsClosing() -> Bool {
    return _windowShouldClose
}

public func getWindowSize() -> (width: Float, height: Float) {
    let size = _glView.frame.size
    return (Float(size.width), Float(size.height))
}

public func getWindowWidth() -> Float {
    let size = _glView.frame.size
    return Float(size.width)
}

public func getWindowHeight() -> Float {
    let size = _glView.frame.size
    return Float(size.height)
}

public func getWindowHiDPISize() -> (width: Float, height: Float) {
    let bounds = _glView.convertToBacking(_glView.bounds)
    return (Float(bounds.size.width), Float(bounds.size.height))
}

public func getWindowHiDPIWidth() -> Float {
    let bounds = _glView.convertToBacking(_glView.bounds)
    return Float(bounds.size.width)
}

public func getWindowHiDPIHeight() -> Float {
    let bounds = _glView.convertToBacking(_glView.bounds)
    return Float(bounds.size.height)
}

// MARK: Screen properties

public func getScreenSize() -> (width: Float, height: Float) {
    guard let screen = _window?.screen else {
        guard let screen = NSScreen.main else { return (0, 0) }
        return (Float(screen.frame.size.width), Float(screen.frame.size.height))
    }
    return (Float(screen.frame.size.width), Float(screen.frame.size.height))
}

public func getScreenWidth() -> Float {
    guard let screen = _window?.screen else {
        guard let screen = NSScreen.main else { return 0 }
        return Float(screen.frame.size.width)
    }
    return Float(screen.frame.size.width)
}

public func getScreenHeight() -> Float {
    guard let screen = _window?.screen else {
        guard let screen = NSScreen.main else { return 0 }
        return Float(screen.frame.size.height)
    }
    return Float(screen.frame.size.height)
}

public func getApplicationSupportDirectory(appname: String? = nil) -> String? {
    var bundleID = Bundle.main.bundleIdentifier
    if bundleID == nil && appname == nil {
        return nil
    } else {
        bundleID = appname
    }
    
    let fm = FileManager.default
    let appSupportDir = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask)
    if appSupportDir.count > 0 {
        let dirPath = appSupportDir[0].appendingPathComponent(bundleID ?? "")
        do {
            try fm.createDirectory(at: dirPath, withIntermediateDirectories: true, attributes: nil)
        } catch  {
            return nil
        }
        return "\(dirPath.path)/"
    }
    
    return nil
}

public func createDirectoryAt(dir: String) throws{
    try FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: false, attributes: nil)
}

public func removeFileAt(filename: String) throws {
    try FileManager.default.removeItem(atPath: filename)
    
}
