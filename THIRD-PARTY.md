# Third-party components

Keypad Studio is only a graphical interface. It bundles and calls the following
third-party software, which does all the actual device communication. All credit
for the reverse-engineering and the USB driver goes to their authors.

---

## ch57x-keyboard-tool  (`bin/ch57x-keyboard-tool.exe`)

- Author: **Mikhail Trishchenkov** (kriomant)
- Project: https://github.com/kriomant/ch57x-keyboard-tool
- Version bundled: **v1.7.0** (official prebuilt Windows binary, unmodified)
- License: **MIT**

```
MIT License

Copyright 2023 Mikhail Trishchenkov

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

The files `bin/example-mapping.yaml` and `docs/actions.md` also come from
that project.

---

## UsbDk — USB Development Kit  (`drivers/UsbDk_1.0.22_x64.msi`)

- Author: **Daynix Computing Ltd.**
- Project: https://github.com/daynix/UsbDk
- Version bundled: **1.0.22** (official installer, unmodified)
- License: **Apache License 2.0** — https://github.com/daynix/UsbDk/blob/master/LICENSE

The installer is redistributed unmodified for convenience. Apache-2.0 permits
redistribution; please refer to the upstream project for the full license text
and NOTICE. USBDK is required on Windows so the tool can access the keyboard
over USB.
