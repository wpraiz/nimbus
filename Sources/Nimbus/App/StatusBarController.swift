import AppKit

final class StatusBarController {

    private var statusItem: NSStatusItem!
    private let captureManager: CaptureManager

    init(captureManager: CaptureManager) {
        self.captureManager = captureManager
        setupStatusBar()
    }

    private func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        guard let button = statusItem.button else { return }
        button.image = NSImage(systemSymbolName: "camera.viewfinder", accessibilityDescription: "Nimbus")
        button.image?.isTemplate = true // auto dark/light mode
        statusItem.menu = buildMenu()
    }

    private func buildMenu() -> NSMenu {
        let menu = NSMenu()

        let captureItem = NSMenuItem(
            title: "Capture Screenshot",
            action: #selector(startCapture),
            keyEquivalent: ""
        )
        captureItem.target = self
        captureItem.image = NSImage(systemSymbolName: "camera", accessibilityDescription: nil)
        menu.addItem(captureItem)

        menu.addItem(.separator())

        let prefsItem = NSMenuItem(
            title: "Preferences…",
            action: #selector(openPreferences),
            keyEquivalent: ","
        )
        prefsItem.target = self
        menu.addItem(prefsItem)

        menu.addItem(.separator())

        menu.addItem(NSMenuItem(
            title: "Quit Nimbus",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        ))

        return menu
    }

    @objc private func startCapture() {
        captureManager.startCapture()
    }

    @objc private func openPreferences() {
        PreferencesViewController.show()
    }
}
