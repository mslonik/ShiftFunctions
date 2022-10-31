# Quick info

Application name: **Shift Diacritic**.

Operating system: Microsoft Windows Ⓡ.

Programming language: AutoHotkey (scripting language for RPA), version 1.1.x.

License: GNU GPL v3.x (GNU's Not Unix! General Public License).

Purpose: entering diacritic characters (e.g. Polish: ą, ć, ę, ł, ó, ń, ś, ź, ż) by combination: basic letter and next Shift modifier.

Author: Maciej Słojewski (🐘), http://mslonik.pl.
<br /><br />

## Chainge log

| Release | Date | Release notes |
| :---         |     :---:      |          :--- |
| 1.0.0   | 2022-10-31     | The first stable release.    |
<br /><br />

## Purpose, detailed

On typical keyboards (layout: ANSI 104-key, form factor: full size = 100%) to enter diacritic characters two keys have to be pressed:
- preliminary or basic key (e.g. a),
- secondary or modifier key (e.g. Right Alt = AltGr).

**Disclaimer**

There are other tactics to enter diacritic characters of course. For example on other than typical keyboards some keys are dedicated to diacritic characters instead of other, less frequently used keys / letters. Or so called "dead key" is used (about [dead key on Wikipedia](https://en.wikipedia.org/wiki/Dead_key)). Please note, the tactics of "dead key" actually is only a variant of secondary or modifier key actually.
<br /><br />
Pressing the secondary [AltGr = alternate graphic](https://en.wikipedia.org/wiki/AltGr_key) is probably the most widespread tactics, but quite problematic:
- There are two **Alt** key modfifiers on each keyboard, but for entering diacritics only the right one is used, what for touch typist is unnatural.
- At typical keyboard It is not easy to reach any **Alt** key by any finger (nor pinky neither thumb).
- The dominant tactics says about pressing down the modifier and then, when modifier is pressed, pressing preliminary key and finally releasing modifier. As a consequence at least two fingers are involved. As there is only one **AltGr** on the keyboard, sometimes two fingers of the same palm should be active.

Remark: actually only **Shift** modifiers are ready to be pressed easily, but with the weakiest finger (pinky).

The **Shift Diacritic** slightly modifies the tactics:
- preliminary keys go first and are pressed as usual,
- as secondary keys (modifiers) are used both **Shift** keys,
- secondary keys (modifiers) are just pressed and released as any other key.

This difference is shown in details on example in the following table:

|  | Typical keyboard | Shift Diacritic |
| :---         |     :---:      |         :---: |
| **preliminary key**   | a     | a    |
| **secondary key**     | AltGr       | Shift (left or right)      |
| **result**            | ą     | ą    |

Order of typing:
| Typical keyboard     |  Comment       |  Shift Diacritic | Comment     |
| :---                 |     :---:      |      :---:       | :---:       |
| AltGr Down           |  git status    |  a down          |             |
| AltGr Down + a Down  |  git diff      |  a up            |             |
| AltGr Down + a Up    |                |  RShift Down     |             |
| AltGr Up             |                |  RShift Up       |             |