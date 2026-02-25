import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {

    private var statusBarController: StatusBarController!
    private let captureManager = CaptureManager()
    private let hotKeyManager = HotKeyManager()
    private let preferencesManager = PreferencesManager.shared

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusBarController = StatusBarController(captureManager: captureManager)
        hotKeyManager.onCapture = { [weak self] in
            self?.captureManager.startCapture()
        }
        hotKeyManager.register(
            keyCode: UInt32(preferencesManager.hotKeyCode),
            modifiers: UInt32(preferencesManager.hotKeyModifiers)
        )
    }

    func applicationWillTerminate(_ notification: Notification) {
        hotKeyManager.unregister()
    }
}
