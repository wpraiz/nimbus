import AppKit
import Carbon.HIToolbox

final class HotKeyManager {

    var onCapture: (() -> Void)?

    private var hotKeyRef: EventHotKeyRef?
    private var eventHandlerRef: EventHandlerRef?
    private static var instances: [HotKeyManager] = []

    func register(keyCode: UInt32, modifiers: UInt32) {
        HotKeyManager.instances.append(self)

        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: OSType(kEventHotKeyPressed)
        )

        let selfPtr = Unmanaged.passUnretained(self).toOpaque()

        InstallEventHandler(
            GetApplicationEventTarget(),
            { (_, _, userData) -> OSStatus in
                guard let ptr = userData else { return OSStatus(eventNotHandledErr) }
                let manager = Unmanaged<HotKeyManager>.fromOpaque(ptr).takeUnretainedValue()
                DispatchQueue.main.async { manager.onCapture?() }
                return noErr
            },
            1, &eventType, selfPtr, &eventHandlerRef
        )

        var hotKeyID = EventHotKeyID()
        hotKeyID.signature = OSType(0x4E4D4253)
        hotKeyID.id = 1

        RegisterEventHotKey(keyCode, modifiers, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef)
    }

    func unregister() {
        if let ref = hotKeyRef { UnregisterEventHotKey(ref); hotKeyRef = nil }
        if let h = eventHandlerRef { RemoveEventHandler(h); eventHandlerRef = nil }
        HotKeyManager.instances.removeAll { $0 === self }
    }
}
