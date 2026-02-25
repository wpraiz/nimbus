import AppKit
import Carbon.HIToolbox

// Manages global hotkey registration using the Carbon framework.
// This works even when other apps are in focus, with no Accessibility permission needed.
final class HotKeyManager {

    var onCapture: (() -> Void)?

    private var hotKeyRef: EventHotKeyRef?
    private var eventHandlerRef: EventHandlerRef?

    func register(keyCode: UInt32, modifiers: UInt32) {
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: OSType(kEventHotKeyPressed)
        )

        // Store self as context pointer for the C callback
        var selfPtr = Unmanaged.passRetained(self).toOpaque()

        InstallEventHandler(
            GetApplicationEventTarget(),
            { (_, event, userData) -> OSStatus in
                guard let ptr = userData else { return OSStatus(eventNotHandledErr) }
                let manager = Unmanaged<HotKeyManager>.fromOpaque(ptr).takeUnretainedValue()
                DispatchQueue.main.async { manager.onCapture?() }
                return noErr
            },
            1, &eventType, selfPtr, &eventHandlerRef
        )

        var hotKeyID = EventHotKeyID()
        hotKeyID.signature = FourCharCode(
            UInt8(ascii: "N") << 24 | UInt8(ascii: "M") << 16 | UInt8(ascii: "B") << 8 | UInt8(ascii: "S")
        )
        hotKeyID.id = 1

        RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
    }

    func unregister() {
        if let ref = hotKeyRef {
            UnregisterEventHotKey(ref)
            hotKeyRef = nil
        }
        if let handler = eventHandlerRef {
            RemoveEventHandler(handler)
            eventHandlerRef = nil
        }
    }
}

extension FourCharCode {
    init(_ value: UInt32) { self = value }
}
