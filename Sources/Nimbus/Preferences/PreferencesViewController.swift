import AppKit

final class PreferencesViewController: NSViewController {

    private static var windowController: NSWindowController?

    static func show() {
        if windowController == nil {
            let vc = PreferencesViewController()
            let win = NSWindow(contentViewController: vc)
            win.title = "Nimbus Preferences"
            win.styleMask = [.titled, .closable]
            win.center()
            windowController = NSWindowController(window: win)
        }
        windowController?.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private let prefs = PreferencesManager.shared

    override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: 380, height: 220))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        buildUI()
    }

    private func buildUI() {
        // Title
        let title = NSTextField(labelWithString: "Nimbus Preferences")
        title.font = .boldSystemFont(ofSize: 16)
        title.frame = CGRect(x: 20, y: 180, width: 340, height: 22)
        view.addSubview(title)

        // Auto-copy URL toggle
        let autoCopyCheck = NSButton(checkboxWithTitle: "Auto-copy link after upload", target: self, action: #selector(toggleAutoCopy(_:)))
        autoCopyCheck.state = prefs.autoCopyURL ? .on : .off
        autoCopyCheck.frame = CGRect(x: 20, y: 145, width: 340, height: 22)
        view.addSubview(autoCopyCheck)

        // Auto-save toggle
        let autoSaveCheck = NSButton(checkboxWithTitle: "Auto-save screenshot to folder", target: self, action: #selector(toggleAutoSave(_:)))
        autoSaveCheck.state = prefs.autoSave ? .on : .off
        autoSaveCheck.frame = CGRect(x: 20, y: 115, width: 340, height: 22)
        view.addSubview(autoSaveCheck)

        // Save folder
        let folderLabel = NSTextField(labelWithString: "Save folder:")
        folderLabel.frame = CGRect(x: 20, y: 82, width: 80, height: 18)
        view.addSubview(folderLabel)

        let folderPath = NSTextField(labelWithString: prefs.saveFolder.path)
        folderPath.frame = CGRect(x: 105, y: 82, width: 195, height: 18)
        folderPath.lineBreakMode = .byTruncatingMiddle
        folderPath.textColor = .secondaryLabelColor
        view.addSubview(folderPath)

        let chooseBtn = NSButton(title: "Choose…", target: self, action: #selector(chooseSaveFolder))
        chooseBtn.frame = CGRect(x: 305, y: 78, width: 60, height: 26)
        view.addSubview(chooseBtn)

        // Hotkey label
        let hotkeyLabel = NSTextField(labelWithString: "Capture shortcut is configured in Preferences → Keyboard.")
        hotkeyLabel.font = .systemFont(ofSize: 11)
        hotkeyLabel.textColor = .tertiaryLabelColor
        hotkeyLabel.frame = CGRect(x: 20, y: 50, width: 340, height: 18)
        view.addSubview(hotkeyLabel)

        // Divider
        let line = NSBox()
        line.boxType = .separator
        line.frame = CGRect(x: 20, y: 40, width: 340, height: 1)
        view.addSubview(line)

        // Version
        let version = NSTextField(labelWithString: "Nimbus 1.0.0 — Open Source ❤️")
        version.font = .systemFont(ofSize: 11)
        version.textColor = .tertiaryLabelColor
        version.frame = CGRect(x: 20, y: 16, width: 340, height: 18)
        view.addSubview(version)
    }

    @objc private func toggleAutoCopy(_ sender: NSButton) {
        prefs.autoCopyURL = sender.state == .on
    }

    @objc private func toggleAutoSave(_ sender: NSButton) {
        prefs.autoSave = sender.state == .on
    }

    @objc private func chooseSaveFolder() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.prompt = "Choose"
        panel.begin { [weak self] response in
            if response == .OK, let url = panel.url {
                self?.prefs.saveFolder = url
                self?.viewDidLoad() // refresh UI
            }
        }
    }
}
