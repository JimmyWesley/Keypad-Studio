# Keypad Studio

A graphical interface (Apple/Logitech style) for configuring your **CH57x macro
keypad** — **12 keys (3×4) + 2 knobs** — on top of the official
[`ch57x-keyboard-tool`](https://github.com/kriomant/ch57x-keyboard-tool).

Everything runs **locally** on your PC. Nothing is sent to the internet.

---

## How to use (one click)

1. Plug the keyboard in with a **USB cable**.
2. (Only to *send* to the keyboard) Install the **USBDK** driver:
   <https://github.com/daynix/UsbDk/releases>
3. **Double‑click `Keypad Studio.bat`** (in the folder above this one).
   - A little black window opens (the *bridge*) — **keep it open**.
   - The browser opens automatically at `http://localhost:8787`.
4. Click a key or knob, pick the action, and click **Send to keyboard**.

To quit, close the little black window.

---

## What you can configure

- **12 keys + 2 knobs** (each knob: turn ↺, press ●, turn ↻).
- **3 layers** — switch them with the button on the side of the keyboard.
- Actions:
  - A single **Key** (letters, numbers, F1–F24, navigation, numpad, symbols…)
  - **Shortcut** (e.g. `ctrl-c`, `ctrl-shift-esc`)
  - **Macro / sequence** (up to 5 steps, optional `delay`) — e.g. type "hi"
  - **Mouse** (click, scroll, move, drag — with modifiers)
  - **Media** (play, volume, brightness, lock screen, browser…)
  - **Advanced** — type the raw CLI syntax, with live validation
- **Lighting (LED)** — modes and colors (depends on your keyboard model).
- **Import / Export** the `.yaml`, plus **Validate** and **Sync**.

The top bar shows the status: **Connected** (green) when the keyboard is detected,
**Preview mode** when you open `index.html` without the bridge.

## Orientation (important!)

Under **Keyboard settings → Orientation**, pick how you **hold** the keyboard:

- **Vertical ↺ (knobs on top)** — the default; this is how the pad stands on a desk.
  The editor then draws **3 columns × 4 rows** and what you click is exactly the
  key you press.
- **Normal (knobs on the right)** — if you use it lying down, knobs to the right.

If the keys come out "scrambled" (you press one and another fires), it's the wrong
orientation — switch it here and send again.

## Sync — bringing back what's on the keyboard

These CH57x keyboards only **write** — there's no way to read back what's stored
(hardware limitation). So the bridge keeps a copy of the **last config sent**
(`studio/.last-config.yaml`). Since nothing else writes to the keyboard, that copy
**is** what's on it. The **Sync** button (and the auto‑load on a fresh session)
brings it back. You can also **save a Profile** or export the `.yaml`.

---

## Structure

```
ch57x-keyboard-tool/
├─ Keypad Studio.bat        ← click here
├─ bin/
│  └─ ch57x-keyboard-tool.exe   (official binary)
└─ studio/
   ├─ index.html           ← the interface
   ├─ bridge.ps1           ← local server (PowerShell)
   └─ README.md
```

## Credits

- CLI: **ch57x-keyboard-tool** © Mikhail Trishchenkov — MIT/Apache‑2.0 license.
- This interface only generates the config and calls the official CLI.
