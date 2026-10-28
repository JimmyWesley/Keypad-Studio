# ⌨️ Keypad Studio

<p align="center">
  <img src="docs/hero.svg" alt="Keypad Studio — GUI for CH57x macro keypads" width="100%">
</p>

An Apple/Logitech‑grade graphical interface for configuring **CH57x macro
keypads** — those **12‑key + 2‑knob** RGB pads that are popular on AliExpress —
built on top of the excellent command‑line tool
[`ch57x-keyboard-tool`](https://github.com/kriomant/ch57x-keyboard-tool).

Everything runs **locally** on your PC (Windows). Nothing is sent to the internet.

> The software that ships with these keyboards is ugly, Windows‑only and only
> programs one key at a time. **Keypad Studio** gives you a clean, complete UI:
> click a key, pick an action, and send it all at once.

---

## ✨ Features

- 🎛️ **Live view of your device** — 12 keys + 2 knobs (turn ↺ · press ● · turn ↻), with RGB.
- 🧩 **3 layers**, switched with the button on the side of the keyboard.
- ⌨️ Per‑key / per‑knob actions:
  - **Key**, **Shortcut** (`ctrl-c`), **Macro/sequence** (up to 5 steps, with `delay`),
  - **Mouse** (click, scroll, move, drag) and **Media** (play, volume, brightness…),
  - an **Advanced** mode with the raw syntax and live validation.
- 🔄 **Sync** — pulls back the last config you sent (the keyboard is write‑only; see below).
- 💡 **Lighting (LED)** — modes (backlight / shock / press) and colors, per layer.
- 💾 **Profiles**, **Import/Export** `.yaml`, and **Validate**.
- 🧭 **Orientation** — draws the keyboard the way you actually hold it (e.g. knobs on top).

---

## 🚀 Install / use (Windows, one click)

1. Plug the keyboard in with a **USB cable**.
2. **Install USBDK** (only needed to *write* to the keyboard):
   double‑click [`drivers/UsbDk_1.0.22_x64.msi`](drivers/) → Next → Finish →
   **reboot**. (Or grab the latest from
   [daynix/UsbDk](https://github.com/daynix/UsbDk/releases).)
3. **Double‑click `Keypad Studio.bat`**.
   - A small black window opens (the local *bridge*) — **keep it open**.
   - Your browser opens automatically at `http://localhost:8787`.
4. Click a key/knob, choose an action, and hit **Send to keyboard**. 🎉

To quit, close the little black window.

> **Preview mode:** you can open `studio/index.html` straight in a browser just to
> build/export a config, but **Validate / Send / LED / Sync** only work when launched
> via `Keypad Studio.bat` (which starts the bridge and talks to the `.exe`).

---

## 🔄 About "reading" the config already on the keyboard

These CH57x keyboards (and the official tool) **can only write** — the USB
communication is one‑way. There is **no way** to read back what's stored on the chip.

Keypad Studio works around this in a practical way: the bridge **keeps a copy of
the last config that was sent** (`studio/.last-config.yaml`). Since nothing else
ever writes to the keyboard, that copy **is** what's on the device. That's why the
**Sync** button (and the automatic load on a fresh session) can bring your config
back even if you never saved it.

---

## 📦 What's in the repo

```
Keypad-Studio/
├─ Keypad Studio.bat         ← click here
├─ studio/
│  ├─ index.html             ← the interface
│  ├─ bridge.ps1             ← local server (PowerShell, native to Windows)
│  ├─ example-layout.yaml    ← example layout (productivity + video editing)
│  └─ README.md
├─ bin/
│  ├─ ch57x-keyboard-tool.exe   (official binary, v1.7.0)
│  └─ example-mapping.yaml
├─ drivers/
│  └─ UsbDk_1.0.22_x64.msi      (USB driver — Daynix)
├─ docs/
│  ├─ hero.svg
│  └─ actions.md             ← every supported action
└─ upstream/
   └─ ch57x-keyboard-tool/   ← full SOURCE CODE (Rust) to build & extend
```

---

## 🛠️ Build & extend

The binary in `bin/` is ready to use, but the **full source code** of the tool is
in [`upstream/ch57x-keyboard-tool/`](upstream/ch57x-keyboard-tool) — so you can
build your own version, add actions, support new models, or build other tools on
top of the mapping.

To build (needs [Rust](https://rustup.rs/)):

```bash
cd upstream/ch57x-keyboard-tool
cargo build --release
# binary produced at: target/release/ch57x-keyboard-tool(.exe)
```

Then copy your `ch57x-keyboard-tool.exe` into the app's `bin/` folder (replacing
the bundled one) — the bridge uses whatever is there.

Good starting points in the code: `src/parse.rs` (action syntax),
`src/keyboard/` (per‑model protocol — e.g. `k884x.rs` for the 0x8842 variant),
`src/config.rs` (YAML format).

---

## 🙏 Credits

This project is just an **interface** on top of third‑party tools — all the
protocol reverse‑engineering is theirs:

- **[ch57x-keyboard-tool](https://github.com/kriomant/ch57x-keyboard-tool)** —
  Mikhail Trishchenkov. MIT license. (Full, unmodified source is included under
  `upstream/ch57x-keyboard-tool/`.)
- **[UsbDk](https://github.com/daynix/UsbDk)** — Daynix. Apache‑2.0 license.

See [THIRD-PARTY.md](THIRD-PARTY.md) for the license notices.

Keypad Studio itself is released under the [MIT](LICENSE) license.
