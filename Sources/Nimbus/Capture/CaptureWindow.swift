import AppKit

// Fullscreen transparent overlay window for region selection.
final class CaptureWindow: NSWindow {

    var onSelectionComplete: ((CGRect) -> Void)?
    var onCancelled: (() -> Void)?

    init(screen: NSScreen) {
        super.init(
            contentRect: screen.frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        level = .screenSaver
        isOpaque = false
        backgroundColor = .clear
        ignoresMouseEvents = false
        acceptsMouseMovedEvents = true
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        let selectionView = SelectionView(frame: screen.frame)
        selectionView.onSelectionComplete = { [weak self] rect in
            self?.onSelectionComplete?(rect)
        }
        selectionView.onCancelled = { [weak self] in
            self?.onCancelled?()
        }
        contentView = selectionView
    }

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}
