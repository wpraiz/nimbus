import AppKit

final class AnnotationViewController: NSViewController {

    // Static ref keeps window alive until user closes
    private static var activeWindow: NSWindow?

    private var canvas: DrawingCanvas!
    private let screenshot: NSImage
    private let sourceRect: CGRect

    static func show(with screenshot: NSImage, sourceRect: CGRect) {
        activeWindow?.close()
        activeWindow = nil

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
        win.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        activeWindow = win
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

    private func setupCanvas() {
        canvas = DrawingCanvas(frame: view.bounds)
        canvas.screenshot = screenshot
        canvas.autoresizingMask = [.width, .height]
        view.addSubview(canvas)
    }

    private func setupDrawToolbar() {
        let tools: [(String, DrawingTool)] = [
            ("arrow.up.right", ArrowTool()),
            ("rectangle",      RectangleTool()),
            ("circle",         EllipseTool()),
            ("line.diagonal",  LineTool()),
            ("pencil",         PencilTool()),
            ("highlighter",    MarkerTool()),
        ]

        let toolbar = FloatingToolbar(axis: .vertical)
        for (icon, tool) in tools {
            toolbar.addButton(icon: icon) { [weak self] in self?.canvas.selectedTool = tool }
        }
        toolbar.addSeparator()
        toolbar.addButton(icon: "paintpalette") { [weak self] in self?.showColorPicker() }
        toolbar.addButton(icon: "arrow.uturn.backward") { [weak self] in self?.canvas.undo() }

        let sz = toolbar.intrinsicContentSize
        toolbar.frame = CGRect(x: -sz.width - 4, y: view.bounds.height/2 - sz.height/2,
                               width: sz.width, height: sz.height)
        view.addSubview(toolbar)
    }

    private func setupActionBar() {
        let actions: [(String, String, () -> Void)] = [
            ("arrow.up.to.line",      "Upload", { [weak self] in self?.upload() }),
            ("doc.on.clipboard",      "Copy",   { [weak self] in self?.copyToClipboard() }),
            ("square.and.arrow.down", "Save",   { [weak self] in self?.saveToDisk() }),
            ("printer",               "Print",  { [weak self] in self?.printImage() }),
            ("xmark",                 "Close",  { [weak self] in self?.closeWindow() }),
        ]

        let bar = FloatingToolbar(axis: .horizontal)
        for (icon, label, action) in actions { bar.addButton(icon: icon, label: label, action: action) }

        let barH: CGFloat = 38
        bar.frame = CGRect(x: 0, y: -barH - 4, width: view.bounds.width, height: barH)
        view.addSubview(bar)
    }

    private func upload() {
        UploadService.shared.upload(image: canvas.renderedImage()) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let url):
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(url, forType: .string)
                    self?.showToast("Link copiado! 🎉")
                case .failure(let e):
                    self?.showToast("Upload falhou: \(e.localizedDescription)")
                }
            }
        }
    }

    private func copyToClipboard() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.writeObjects([canvas.renderedImage()])
        showToast("Copiado!")
    }

    private func saveToDisk() {
        let folder = PreferencesManager.shared.saveFolder
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let url = folder.appendingPathComponent("Screenshot \(formattedDate()).png")
        guard let tiff = canvas.renderedImage().tiffRepresentation,
              let bmp = NSBitmapImageRep(data: tiff),
              let png = bmp.representation(using: .png, properties: [:]) else { return }
        try? png.write(to: url)
        showToast("Salvo em \(folder.lastPathComponent)!")
    }

    private func printImage() {
        let v = NSImageView(image: canvas.renderedImage())
        NSPrintOperation(view: v).run()
    }

    private func showColorPicker() {
        NSColorPanel.shared.isVisible
            ? NSColorPanel.shared.close()
            : NSColorPanel.shared.makeKeyAndOrderFront(nil)
        NSColorPanel.shared.setTarget(self)
        NSColorPanel.shared.setAction(#selector(colorChanged(_:)))
    }

    @objc private func colorChanged(_ sender: NSColorPanel) { canvas.selectedColor = sender.color }

    private func closeWindow() {
        AnnotationViewController.activeWindow?.close()
        AnnotationViewController.activeWindow = nil
    }

    private func showToast(_ msg: String) {
        let label = NSTextField(labelWithString: msg)
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .white
        label.backgroundColor = NSColor.black.withAlphaComponent(0.8)
        label.isBezeled = false; label.isEditable = false
        label.sizeToFit()
        let p: CGFloat = 12
        label.frame = CGRect(x: view.bounds.midX - label.frame.width/2 - p,
                             y: view.bounds.midY - 15,
                             width: label.frame.width + p*2, height: 30)
        view.addSubview(label)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            NSAnimationContext.runAnimationGroup({ $0.duration = 0.3; label.animator().alphaValue = 0 }) {
                label.removeFromSuperview()
            }
        }
    }

    private func formattedDate() -> String {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd HH.mm.ss"; return f.string(from: Date())
    }
}
