import AppKit

// The interactive view drawn on top of the screen for region selection.
// Shows a dimmed overlay, a crosshair cursor, and a live size badge.
final class SelectionView: NSView {

    var onSelectionComplete: ((CGRect) -> Void)?
    var onCancelled: (() -> Void)?

    private var startPoint: NSPoint?
    private var currentRect: CGRect?
    private var isDragging = false

    // MARK: - Setup

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        NSCursor.crosshair.set()
    }

    // MARK: - Drawing

    override func draw(_ dirtyRect: NSRect) {
        // Full overlay dim
        NSColor.black.withAlphaComponent(0.45).setFill()
        bounds.fill()

        guard let rect = currentRect, isDragging else { return }

        // Clear the selected region (punch-through effect)
        NSGraphicsContext.current?.cgContext.clear(rect)

        // Selection border
        let border = NSBezierPath(rect: rect)
        border.lineWidth = 1.5
        NSColor.white.withAlphaComponent(0.9).setStroke()
        border.stroke()

        // Corner handles
        drawHandles(in: rect)

        // Size badge
        drawSizeBadge(for: rect)
    }

    private func drawHandles(in rect: CGRect) {
        let size: CGFloat = 6
        let corners: [CGPoint] = [
            rect.origin,
            CGPoint(x: rect.maxX, y: rect.minY),
            CGPoint(x: rect.minX, y: rect.maxY),
            CGPoint(x: rect.maxX, y: rect.maxY)
        ]
        NSColor.white.setFill()
        for corner in corners {
            let dot = CGRect(x: corner.x - size/2, y: corner.y - size/2, width: size, height: size)
            NSBezierPath(ovalIn: dot).fill()
        }
    }

    private func drawSizeBadge(for rect: CGRect) {
        let text = "\(Int(rect.width)) × \(Int(rect.height))"
        let attrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedSystemFont(ofSize: 11, weight: .medium),
            .foregroundColor: NSColor.white
        ]
        let size = (text as NSString).size(withAttributes: attrs)
        let padding: CGFloat = 6
        let badgeRect = CGRect(
            x: rect.midX - size.width/2 - padding,
            y: rect.maxY + 8,
            width: size.width + padding * 2,
            height: size.height + padding
        )
        let bg = NSBezierPath(roundedRect: badgeRect, xRadius: 4, yRadius: 4)
        NSColor.black.withAlphaComponent(0.7).setFill()
        bg.fill()
        (text as NSString).draw(
            at: CGPoint(x: badgeRect.minX + padding, y: badgeRect.minY + padding / 2),
            withAttributes: attrs
        )
    }

    // MARK: - Mouse Events

    override func mouseDown(with event: NSEvent) {
        startPoint = convert(event.locationInWindow, from: nil)
        currentRect = nil
        isDragging = false
        needsDisplay = true
    }

    override func mouseDragged(with event: NSEvent) {
        guard let start = startPoint else { return }
        let current = convert(event.locationInWindow, from: nil)
        isDragging = true
        currentRect = CGRect(
            x: min(start.x, current.x),
            y: min(start.y, current.y),
            width: abs(current.x - start.x),
            height: abs(current.y - start.y)
        )
        needsDisplay = true
    }

    override func mouseUp(with event: NSEvent) {
        guard isDragging, let rect = currentRect, rect.width > 5, rect.height > 5 else {
            onCancelled?()
            return
        }
        onSelectionComplete?(rect)
    }

    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 { // Escape
            onCancelled?()
        }
    }

    override var acceptsFirstResponder: Bool { true }
}
