import AppKit

// Represents a single annotation stroke/shape drawn on the canvas.
struct Annotation {
    enum Tool {
        case arrow, rectangle, ellipse, line, pencil, marker, text(String)
    }
    var tool: Tool
    var path: NSBezierPath
    var color: NSColor
    var lineWidth: CGFloat
}

// Protocol all drawing tools conform to.
protocol DrawingTool {
    var cursor: NSCursor { get }
    func startPath(at point: CGPoint, color: NSColor, lineWidth: CGFloat) -> Annotation
    func updatePath(_ annotation: inout Annotation, to point: CGPoint)
}

// MARK: - Tool Implementations

struct ArrowTool: DrawingTool {
    var cursor: NSCursor { .crosshair }

    func startPath(at point: CGPoint, color: NSColor, lineWidth: CGFloat) -> Annotation {
        Annotation(tool: .arrow, path: NSBezierPath(), color: color, lineWidth: lineWidth)
    }

    func updatePath(_ annotation: inout Annotation, to point: CGPoint) {
        let start = annotation.path.isEmpty ? point : annotation.path.currentPoint
        annotation.path = arrowPath(from: start, to: point, lineWidth: annotation.lineWidth)
    }

    private func arrowPath(from start: CGPoint, to end: CGPoint, lineWidth: CGFloat) -> NSBezierPath {
        let path = NSBezierPath()
        let angle = atan2(end.y - start.y, end.x - start.x)
        let headLength = lineWidth * 5 + 10
        let headAngle: CGFloat = .pi / 6

        path.move(to: start)
        path.line(to: end)

        path.move(to: end)
        path.line(to: CGPoint(
            x: end.x - headLength * cos(angle - headAngle),
            y: end.y - headLength * sin(angle - headAngle)
        ))
        path.move(to: end)
        path.line(to: CGPoint(
            x: end.x - headLength * cos(angle + headAngle),
            y: end.y - headLength * sin(angle + headAngle)
        ))
        return path
    }
}

struct RectangleTool: DrawingTool {
    var cursor: NSCursor { .crosshair }

    func startPath(at point: CGPoint, color: NSColor, lineWidth: CGFloat) -> Annotation {
        Annotation(tool: .rectangle, path: NSBezierPath(rect: .zero), color: color, lineWidth: lineWidth)
    }

    func updatePath(_ annotation: inout Annotation, to point: CGPoint) {
        guard let start = annotation.path.isEmpty ? nil : Optional(annotation.path.currentPoint) else { return }
        let rect = CGRect(
            x: min(start.x, point.x), y: min(start.y, point.y),
            width: abs(point.x - start.x), height: abs(point.y - start.y)
        )
        annotation.path = NSBezierPath(rect: rect)
    }
}

struct EllipseTool: DrawingTool {
    var cursor: NSCursor { .crosshair }

    func startPath(at point: CGPoint, color: NSColor, lineWidth: CGFloat) -> Annotation {
        Annotation(tool: .ellipse, path: NSBezierPath(ovalIn: .zero), color: color, lineWidth: lineWidth)
    }

    func updatePath(_ annotation: inout Annotation, to point: CGPoint) {
        guard let start = annotation.path.isEmpty ? nil : Optional(annotation.path.currentPoint) else { return }
        let rect = CGRect(
            x: min(start.x, point.x), y: min(start.y, point.y),
            width: abs(point.x - start.x), height: abs(point.y - start.y)
        )
        annotation.path = NSBezierPath(ovalIn: rect)
    }
}

struct PencilTool: DrawingTool {
    var cursor: NSCursor { .pencil }

    func startPath(at point: CGPoint, color: NSColor, lineWidth: CGFloat) -> Annotation {
        let path = NSBezierPath()
        path.move(to: point)
        return Annotation(tool: .pencil, path: path, color: color, lineWidth: lineWidth)
    }

    func updatePath(_ annotation: inout Annotation, to point: CGPoint) {
        annotation.path.line(to: point)
    }
}

struct MarkerTool: DrawingTool {
    var cursor: NSCursor { .pencil }

    func startPath(at point: CGPoint, color: NSColor, lineWidth: CGFloat) -> Annotation {
        let path = NSBezierPath()
        path.move(to: point)
        return Annotation(tool: .marker, path: path, color: color, lineWidth: lineWidth * 4)
    }

    func updatePath(_ annotation: inout Annotation, to point: CGPoint) {
        annotation.path.line(to: point)
    }
}

struct LineTool: DrawingTool {
    var cursor: NSCursor { .crosshair }
    private var startPoint: CGPoint?

    func startPath(at point: CGPoint, color: NSColor, lineWidth: CGFloat) -> Annotation {
        let path = NSBezierPath()
        path.move(to: point)
        return Annotation(tool: .line, path: path, color: color, lineWidth: lineWidth)
    }

    func updatePath(_ annotation: inout Annotation, to point: CGPoint) {
        let start = annotation.path.currentPoint
        annotation.path = NSBezierPath()
        annotation.path.move(to: start)
        annotation.path.line(to: point)
    }
}
