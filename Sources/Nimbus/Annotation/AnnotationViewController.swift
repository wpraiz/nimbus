import AppKit

// Full annotation UI: screenshot canvas + floating toolbars.
// Shown after the user completes a screen selection.
final class AnnotationViewController: NSViewController {

    private var canvas: DrawingCanvas!
    private let screenshot: NSImage
    private let sourceRect: CGRect
    private var window: NSWindow?

    static func show(with screenshot: NSImage, sourceRect: CGRect) {
        let vc = AnnotationViewController(screenshot: screenshot, sourceRect: sourceRect)
        let win = NSWindow(
            contentRect: sourceRect,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        win.level = .floating
        win.isOpaque = false
        win.backgroundColor = .clear
        win.contentViewController = vc
        vc.window = win
        win.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    init(screenshot: NSImage, sourceRect: CGRect) {
        self.screenshot = screenshot
        self.sourceRect = sourceRect
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func loadView() {
        view = NSView(frame: CGRect(origin: .zero, size: sourceRect.size))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCanvas()
        setupDrawToolbar()
        setupActionBar()
    }

    // MARK: - Canvas

    private func setupCanvas() {
        canvas = DrawingCanvas(frame: view.bounds)
        canvas.screenshot = screenshot
        canvas.autoresizingMask = [.width, .height]
        view.addSubview(canvas)
    }

    // MARK: - Drawing Toolbar (left side)

    private func setupDrawToolbar() {
        let tools: [(String, DrawingTool)] = [
            ("arrow.up.right",     ArrowTool()),
            ("rectangle",          RectangleTool()),
            ("circle",             EllipseTool()),
            ("line.diagonal",      LineTool()),
            ("pencil",             PencilTool()),
            ("highlighter",        MarkerTool()),
        ]

        let toolbar = FloatingToolbar(axis: .vertical)
        for (icon, tool) in tools {
            toolbar.addButton(icon: icon) { [weak self] in
                self?.canvas.selectedTool = tool
            }
        }

        toolbar.addSeparator()

        // Color picker
        toolbar.addButton(icon: "paintpalette") { [weak self] in
            self?.showColorPicker()
        }

        // Undo
        toolbar.addButton(icon: "arrow.uturn.backward") { [weak self] in
            self?.canvas.undo()
        }

        let toolbarWidth: CGFloat = 36
        toolbar.frame = CGRect(
            x: -toolbarWidth - 4,
            y: view.bounds.height / 2 - toolbar.intrinsicContentSize.height / 2,
            width: toolbarWidth,
            height: toolbar.intrinsicContentSize.height
        )
        view.addSubview(toolbar)
    }

    // MARK: - Action Bar (bottom)

    private func setupActionBar() {
        let actions: [(String, String, () -> Void)] = [
            ("arrow.up.to.line",   "Upload",  { [weak self] in self?.upload() }),
            ("doc.on.clipboard",   "Copy",    { [weak self] in self?.copyToClipboard() }),
            ("square.and.arrow.down", "Save", { [weak self] in self?.saveToDisk() }),
            ("printer",            "Print",   { [weak self] in self?.print() }),
            ("xmark",              "Close",   { [weak self] in self?.closeWindow() }),
        ]

        let actionBar = FloatingToolbar(axis: .horizontal)
        for (icon, label, action) in actions {
            actionBar.addButton(icon: icon, label: label, action: action)
        }

        let barHeight: CGFloat = 38
        actionBar.frame = CGRect(
            x: 0,
            y: -barHeight - 4,
            width: view.bounds.width,
            height: barHeight
        )
        view.addSubview(actionBar)
    }

    // MARK: - Actions

    private func upload() {
        let image = canvas.renderedImage()
        UploadService.shared.upload(image: image) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let url):
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(url, forType: .string)
                    self?.showToast("Link copied! 🎉")
                case .failure(let error):
                    self?.showToast("Upload failed: \(error.localizedDescription)")
                }
            }
        }
    }

    private func copyToClipboard() {
        let image = canvas.renderedImage()
        NSPasteboard.general.clearContents()
        NSPasteboard.general.writeObjects([image])
        showToast("Copied to clipboard!")
    }

    private func saveToDisk() {
        let image = canvas.renderedImage()
        let saveURL = PreferencesManager.shared.saveFolder
            .appendingPathComponent("Screenshot \(formattedDate()).png")

        guard let tiff = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiff),
              let png = bitmap.representation(using: .png, properties: [:]) else { return }

        try? png.write(to: saveURL)
        showToast("Saved!")
    }

    private func print() {
        let image = canvas.renderedImage()
        let imageView = NSImageView(image: image)
        let printOp = NSPrintOperation(view: imageView)
        printOp.run()
    }

    private func showColorPicker() {
        NSColorPanel.shared.isVisible ? NSColorPanel.shared.close() : NSColorPanel.shared.makeKeyAndOrderFront(nil)
        NSColorPanel.shared.setTarget(self)
        NSColorPanel.shared.setAction(#selector(colorChanged(_:)))
    }

    @objc private func colorChanged(_ sender: NSColorPanel) {
        canvas.selectedColor = sender.color
    }

    private func closeWindow() {
        window?.close()
    }

    private func showToast(_ message: String) {
        let label = NSTextField(labelWithString: message)
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .white
        label.backgroundColor = NSColor.black.withAlphaComponent(0.8)
        label.isBezeled = false
        label.isEditable = false
        label.sizeToFit()

        let padding: CGFloat = 12
        let frame = CGRect(
            x: view.bounds.midX - label.frame.width/2 - padding,
            y: view.bounds.midY - 15,
            width: label.frame.width + padding*2,
            height: 30
        )
        label.frame = frame
        view.addSubview(label)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            NSAnimationContext.runAnimationGroup({ ctx in
                ctx.duration = 0.3
                label.animator().alphaValue = 0
            }, completionHandler: { label.removeFromSuperview() })
        }
    }

    private func formattedDate() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH.mm.ss"
        return f.string(from: Date())
    }
}
