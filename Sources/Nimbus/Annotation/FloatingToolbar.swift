import AppKit

// Reusable floating toolbar — used for both draw tools (vertical) and action bar (horizontal).
final class FloatingToolbar: NSView {

    enum Axis { case horizontal, vertical }

    private let axis: Axis
    private var buttons: [NSView] = []
    private let buttonSize: CGFloat = 28
    private let spacing: CGFloat = 4
    private let padding: CGFloat = 6

    init(axis: Axis) {
        self.axis = axis
        super.init(frame: .zero)
        wantsLayer = true
        layer?.cornerRadius = 8
        layer?.backgroundColor = NSColor.black.withAlphaComponent(0.78).cgColor
    }

    required init?(coder: NSCoder) { fatalError() }

    func addButton(icon: String, label: String? = nil, action: @escaping () -> Void) {
        let btn = NimbusButton(icon: icon, label: label, size: buttonSize, action: action)
        buttons.append(btn)
        addSubview(btn)
        relayout()
    }

    func addSeparator() {
        let sep = NSView()
        sep.wantsLayer = true
        sep.layer?.backgroundColor = NSColor.white.withAlphaComponent(0.15).cgColor
        buttons.append(sep)
        addSubview(sep)
        relayout()
    }

    override var intrinsicContentSize: CGSize {
        let total = buttons.reduce(0.0) { sum, btn in
            sum + (btn is NSView && !(btn is NimbusButton) ? 1.0 : buttonSize) + spacing
        } - spacing + padding * 2

        return axis == .vertical
            ? CGSize(width: buttonSize + padding * 2, height: total)
            : CGSize(width: total, height: buttonSize + padding * 2)
    }

    private func relayout() {
        frame.size = intrinsicContentSize
        var offset = padding

        for btn in buttons {
            let isSeparator = !(btn is NimbusButton)
            let size: CGFloat = isSeparator ? 1 : buttonSize

            if axis == .vertical {
                btn.frame = CGRect(x: padding, y: offset, width: buttonSize, height: size)
            } else {
                let width = btn is NimbusButton ? (btn as! NimbusButton).preferredWidth : 1
                btn.frame = CGRect(x: offset, y: padding, width: width, height: buttonSize)
                offset += width + spacing
                continue
            }
            offset += size + spacing
        }
    }
}

// Individual button used inside FloatingToolbar
private final class NimbusButton: NSView {

    var preferredWidth: CGFloat { label != nil ? 60 : size }

    private let size: CGFloat
    private let action: () -> Void
    private let icon: String
    private let label: String?
    private var isHovered = false

    init(icon: String, label: String?, size: CGFloat, action: @escaping () -> Void) {
        self.icon = icon
        self.label = label
        self.size = size
        self.action = action
        super.init(frame: .zero)
        addTrackingArea(NSTrackingArea(
            rect: .zero,
            options: [.activeAlways, .inVisibleRect, .mouseEnteredAndExited],
            owner: self
        ))
    }

    required init?(coder: NSCoder) { fatalError() }

    override func draw(_ dirtyRect: NSRect) {
        if isHovered {
            NSColor.white.withAlphaComponent(0.15).setFill()
            NSBezierPath(roundedRect: bounds.insetBy(dx: 2, dy: 2), xRadius: 5, yRadius: 5).fill()
        }

        let config = NSImage.SymbolConfiguration(pointSize: 13, weight: .medium)
        if let img = NSImage(systemSymbolName: icon, accessibilityDescription: nil)?
            .withSymbolConfiguration(config) {
            img.isTemplate = true

            var tinted = img
            if let t = tintedImage(img, color: .white) { tinted = t }

            let imgSize = tinted.size
            if let lbl = label {
                // icon above, label below
                let imgRect = CGRect(x: (bounds.width - imgSize.width)/2, y: 18, width: imgSize.width, height: imgSize.height)
                tinted.draw(in: imgRect)
                let attrs: [NSAttributedString.Key: Any] = [
                    .font: NSFont.systemFont(ofSize: 9),
                    .foregroundColor: NSColor.white.withAlphaComponent(0.8)
                ]
                (lbl as NSString).draw(
                    at: CGPoint(x: (bounds.width - (lbl as NSString).size(withAttributes: attrs).width) / 2, y: 4),
                    withAttributes: attrs
                )
            } else {
                let imgRect = CGRect(
                    x: (bounds.width - imgSize.width)/2,
                    y: (bounds.height - imgSize.height)/2,
                    width: imgSize.width, height: imgSize.height
                )
                tinted.draw(in: imgRect)
            }
        }
    }

    private func tintedImage(_ image: NSImage, color: NSColor) -> NSImage? {
        let tinted = image.copy() as? NSImage
        tinted?.lockFocus()
        color.set()
        let rect = NSRect(origin: .zero, size: image.size)
        rect.fill(using: .sourceAtop)
        tinted?.unlockFocus()
        return tinted
    }

    override func mouseEntered(with event: NSEvent) { isHovered = true; needsDisplay = true }
    override func mouseExited(with event: NSEvent) { isHovered = false; needsDisplay = true }
    override func mouseUp(with event: NSEvent) { action() }
}
