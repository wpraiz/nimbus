import AppKit

// Orchestrates the full capture flow:
// 1. Show fullscreen overlay for region selection
// 2. Capture the selected region
// 3. Hand off screenshot to AnnotationViewController
final class CaptureManager {

    private var captureWindow: CaptureWindow?

    func startCapture() {
        // Slight delay so the menu dismisses before overlay appears
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            self?.showOverlay()
        }
    }

    private func showOverlay() {
        guard let screen = NSScreen.main else { return }
        captureWindow = CaptureWindow(screen: screen)
        captureWindow?.onSelectionComplete = { [weak self] rect in
            self?.captureRegion(rect, on: screen)
        }
        captureWindow?.onCancelled = { [weak self] in
            self?.captureWindow = nil
        }
        captureWindow?.makeKeyAndOrderFront(nil)
    }

    private func captureRegion(_ selectionRect: CGRect, on screen: NSScreen) {
        captureWindow?.close()
        captureWindow = nil

        // Wait for the overlay window to fully disappear before capturing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            let screenHeight = screen.frame.height
            let cgRect = CGRect(
                x: selectionRect.origin.x,
                y: screenHeight - selectionRect.origin.y - selectionRect.height,
                width: selectionRect.width,
                height: selectionRect.height
            )

            guard let screenshot = CGWindowListCreateImage(
                cgRect,
                .optionOnScreenOnly,
                kCGNullWindowID,
                [.bestResolution, .nominalResolution]
            ) else { return }

            let image = NSImage(cgImage: screenshot, size: selectionRect.size)
            AnnotationViewController.show(with: image, sourceRect: selectionRect)
        }
    }
}
