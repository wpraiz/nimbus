<div align="center">

<img src="https://img.shields.io/badge/macOS-13%2B-black?style=flat-square&logo=apple" />
<img src="https://img.shields.io/badge/Swift-5.9-orange?style=flat-square&logo=swift" />
<img src="https://img.shields.io/badge/License-MIT-blue?style=flat-square" />
<img src="https://img.shields.io/badge/status-active-brightgreen?style=flat-square" />
<img src="https://img.shields.io/badge/Apple%20Silicon-native-black?style=flat-square" />

<br /><br />

```
███╗   ██╗██╗███╗   ███╗██████╗ ██╗   ██╗███████╗
████╗  ██║██║████╗ ████║██╔══██╗██║   ██║██╔════╝
██╔██╗ ██║██║██╔████╔██║██████╔╝██║   ██║███████╗
██║╚██╗██║██║██║╚██╔╝██║██╔══██╗██║   ██║╚════██║
██║ ╚████║██║██║ ╚═╝ ██║██████╔╝╚██████╔╝███████║
╚═╝  ╚═══╝╚═╝╚═╝     ╚═╝╚═════╝  ╚═════╝ ╚══════╝
```

### The Lightshot experience — reborn for modern macOS.

*Lightweight. Native. Open Source.*

<br />

[**Download**](#installation) · [**Features**](#features) · [**Contributing**](#contributing) · [**Roadmap**](#roadmap)

</div>

---

> **The story:** Lightshot was removed from the Mac App Store. Millions of users were left without their favourite screenshot tool — no migration, no explanation.  
> Nimbus is the open-source answer. Same workflow, same speed, built natively for Apple Silicon with everything the original was missing.

---

## ✨ Features

| | Feature | Details |
|---|---|---|
| 📸 | **Region capture** | Drag to select any area of your screen. Instant overlay, live size indicator. |
| ✏️ | **Annotation tools** | Arrow, Rectangle, Ellipse, Line, Pencil, Marker, Text — with color picker |
| ⬆️ | **One-click upload** | Uploads to Imgur and **auto-copies the link** to your clipboard |
| 💾 | **Save anywhere** | Save screenshots to any folder. Configurable. |
| ⌨️ | **Global hotkey** | Capture from any app. Fully customisable shortcut. |
| 🍎 | **Native Apple Silicon** | Built with AppKit. Zero Electron. Zero Rosetta. |
| 🎨 | **SF Symbols UI** | Beautiful, system-native toolbar icons that follow your theme |
| 🔒 | **Privacy first** | No account required. Uploads are anonymous. Nothing phoned home. |

---

## 🚀 Installation

### Homebrew (coming soon)
```bash
brew install --cask nimbus-screenshot
```

### Build from source
```bash
git clone git@github.com:wpraiz/nimbus.git
cd nimbus
open Package.swift   # Opens in Xcode
```
Then press **⌘R** to run.

> Requires Xcode 15+ and macOS 13+

---

## 🎯 How it works

1. Press your hotkey (default: `⌘4`)
2. Drag to select a region
3. Annotate with the toolbar
4. Hit **Upload** → link is copied to clipboard automatically  
   — or **Save** to your configured folder

That's it. No account. No login. No bloat.

---

## 🗺️ Roadmap

- [x] Region selection with dimmed overlay
- [x] Annotation toolbar (arrow, rect, ellipse, line, pencil, marker)
- [x] Imgur upload + auto-copy URL
- [x] Save to custom folder
- [x] Global hotkey with Carbon API
- [x] Preferences panel
- [ ] Scrolling capture (full page)
- [ ] OCR (copy text from screenshot)
- [ ] Screenshot history panel
- [ ] Custom upload server support (self-hosted)
- [ ] Homebrew tap
- [ ] Mac App Store release

---

## 🛠️ Architecture

```
Sources/Nimbus/
├── App/
│   ├── main.swift                   # NSApplication bootstrap
│   ├── AppDelegate.swift            # Wires everything together
│   └── StatusBarController.swift    # Menu bar icon + menu
├── Capture/
│   ├── CaptureManager.swift         # Orchestrates the capture flow
│   ├── CaptureWindow.swift          # Fullscreen overlay window
│   └── SelectionView.swift          # Rubber-band selection + size badge
├── Annotation/
│   ├── AnnotationViewController.swift  # Main annotation UI
│   ├── DrawingCanvas.swift             # NSView with live drawing
│   ├── DrawingTool.swift               # Protocol + Arrow/Rect/Pencil/... tools
│   └── FloatingToolbar.swift           # Reusable dark floating toolbar
├── Upload/
│   └── UploadService.swift          # Imgur API + auto-copy
├── HotKey/
│   └── HotKeyManager.swift          # Carbon RegisterEventHotKey
└── Preferences/
    ├── PreferencesManager.swift     # NSUserDefaults wrapper
    └── PreferencesViewController.swift
```

---

## 🤝 Contributing

This is a community project. PRs are very welcome!

```bash
git clone git@github.com:wpraiz/nimbus.git
cd nimbus
open Package.swift
```

**Good first issues:**
- [ ] Add text annotation tool with inline editing
- [ ] Scrolling / window capture mode
- [ ] Screenshot history (last 20 captures in menu)
- [ ] Custom upload server endpoint

Please keep PRs small and focused. One feature per PR.

---

## 📄 License

MIT © [wpraiz](https://github.com/wpraiz)

---

<div align="center">

Made with ❤️ because Lightshot deserved a proper goodbye — and a proper successor.

**Star ⭐ this repo if Lightshot meant something to you.**

</div>
