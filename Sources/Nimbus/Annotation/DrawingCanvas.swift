import AppKit

// NSView that renders the captured screenshot + live annotation layers.
final class DrawingCanvas: NSView {

    var screenshot: NSImage?
    private(set) var annotations: [Annotation] = []
    private var currentAnnotation: Annotation?

    var selectedTool: DrawingTool = ArrowTool()
    var selectedColor: NSColor = .systemRed
    var lineWidth: CGFloat = 2

    var canUndo: Bool { !annotations.isEmpty }

    // MARK: - Drawing

    override func draw(_ dirtyRect: NSRect) {
        // Screenshot background
        screenshot?.draw(in: bounds)

        // Committed annotations
        for annotation in annotations {
            draw(annotation)
        }

        // In-progress annotation
        if let current = currentAnnotation {
            draw(current)
        }
    }

    private func draw(_ annotation: Annotation) {
        NSGraphicsContext.current?.saveGraphicsState()
        annotation.path.lineWidth = annotation.lineWidth
        annotation.path.lineCapStyle = .round
        annotation.path.lineJoinStyle = .round

        switch annotation.tool {
        case .marker:
            annotation.color.withAlphaComponent(0.4).setStroke()
        case .text(let string):
            let attrs: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: 16, weight: .semibold),
                .foregroundColor: annotation.color
            ]
            string.draw(at: annotation.path.currentPoint, withAttributes: attrs)
            NSGraphicsContext.current?.restoreGraphicsState()
            return
        default:
            annotation.color.setStroke()
        }

        annotation.path.stroke()
        NSGraphicsContext.current?.restoreGraphicsState()
    }

    // MARK: - Mouse Events

    override func mouseDown(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        currentAnnotation = selectedTool.startPath(at: point, color: selectedColor, lineWidth: lineWidth)
        needsDisplay = true
    }

    override func mouseDragged(with event: NSEvent) {
        guard currentAnnotation != nil else { return }
        let point = convert(event.locationInWindow, from: nil)
        selectedTool.updatePath(&currentAnnotation!, to: point)
        needsDisplay = true
    }

    override func mouseUp(with event: NSEvent) {
        if let annotation = currentAnnotation {
            annotations.append(annotation)
            currentAnnotation = nil
            needsDisplay = true
        }
    }

    // MARK: - Actions

    func undo() {
        guard !annotations.isEmpty else { return }
        annotations.removeLast()
        needsDisplay = true
    }

    func renderedImage() -> NSImage {
        let image = NSImage(size: bounds.size)
        image.lockFocus()
        draw(bounds)
        image.unlockFocus()
        return image
    }

    override var acceptsFirstResponder: Bool { true }
}
