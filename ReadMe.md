# Quick info

Application name: **Shift Diacritic**.

Operating system: Microsoft Windows Ⓡ.

Programming language: AutoHotkey (scripting language for RPA), version 1.1.x.

License: GNU GPL v3.x (GNU's Not Unix! General Public License).

Purpose: entering diacritic characters (e.g. Polish: ą, ć, ę, ł, ó, ń, ś, ź, ż) by pressing combination of keyboard keys: basic letter and next Shift modifier.

Author: Maciej Słojewski (🐘), http://mslonik.pl.
<br /><br />

## Chainge log

| Release |    Date    | Release notes             |
| :------ | :--------: | :------------------------ |
| 1.0.0   | 2022-10-31 | The first stable release. |

<br /><br />

## Purpose, detailed

### What are diacritic characters?

[Diacritic](https://en.wikipedia.org/wiki/Diacritic) characters are based on ordinary (basic) latin letters to distinguish them by glyphs (accent, acute, grave etc.).

For example in Polish language:

| basic         |  a  |  c  |  e  |  l  |  o  |  n  |  s  |  x  |  z  |
| :------------ | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
| **diacritic** |  ą  |  ć  |  ę  |  ł  |  ó  |  ń  |  ś  |  ź  |  ż  |
| **no.**       |  1  |  2  |  3  |  4  |  5  |  6  |  7  |  9  |  8  |

| basic capital         |  A  |  C  |  E  |  L  |  O  |  N  |  S  |  X  |  Z  |
| :-------------------- | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
| **diacritic** capital |  Ą  |  Ć  |  Ę  |  Ł  |  Ó  |  Ń  |  Ś  |  Ź  |  Ż  |
| **no.**               | 10  | 11  | 12  | 13  | 14  | 15  | 16  | 18  | 17  |

### What is the purpose?

The purpose is to enable user to enter diacritic characters on his (her) keyboard.

### About PC (🖥 aka. Personal Computer) keyboard (🖮)

Computer keyboard features:

- layouts (how keys are arranged on keyboard)
- form factor (size / amount of keys)

#### Keyboard layouts

- ANSI 104 key (at form factor 100%), I would call it **typical** in former part of this article
- ISO 105 key (at form factor 100%)
- Asian
- others (e.g. Focus, JIS, HHKB, legacy AT/XT)

If you wish to know more about this subject, [check it out](https://youtu.be/zIVdOidXaOw).

#### Form factor

Form factor doesn't play a major role in the following considerations. If you wish to investigate this subject, [check it out](https://youtu.be/_EZvYNF_fuA).

### What is the challenge?

The **typical** keyboard is populatd with basic latin characters and some alphanumeric characters / symbols. There is no room for additional characters. The challenge is to fit or enable to user to enter **diacritic** characters on existing layout.

### Solutions

There are discussed two approaches

- system (operating system)
- personal

#### Operating system level

I would focus only on Microsoft Windows level. There keyboard settings are associated with language. For example for Polish language we have two presettings:

- Polish (programmers),
- Polish (typist keyboard).

Of course you can also use

- "basic" English (United States keyboard layout)

Let's examine differences taking into consideration **typical** layout.

| operating system level      |                          "basic" English                          |                                                   Polish (programmers)                                                    |                                                                                   Polish (typist keyboard)                                                                                   |
| :-------------------------- | :---------------------------------------------------------------: | :-----------------------------------------------------------------------------------------------------------------------: | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: |
| general tactics description | No diacritics. Only latin characters. No "dead key". AltGr = Alt. | Keyboard keycaps as for English "basic". Diacritics located "under" basic characters. Access via "dead key" (~) or AltGr. | Specific keyboard layout (keycaps) for basic layer where diacritics are directly available and AltGr for layer with additional alphanumeric keys. "Dead key" is also applied as alternative. |
| general tactics in short    |                           no diacritics                           |                                  English keycaps, concept of layer (AltGr), dead key (~)                                  |                                                                    Polish keycaps, concpet of layer (AltGr), dead key (~)                                                                    |
| dominant tactics            |                          not applicable                           |                                         English keycaps, concept of layer (AltGr)                                         |                                                                           Polish keycaps, concpet of layer (AltGr)                                                                           |

By dominant tactics I understand how people actually use keyboard to enter diacritics.

Let's sum up:

- there are not enough room to "fit them all": not enough room on hardware platform to keep all required symbols on keys,
- to enter specific keys user has to press most of the time more than one key,
- now it is the choice which keys to choose for which layer and how to organize layers.

Operating system uses the following concepts, which will be described below in details:

- layers,
- dead key(s),
- sticky keys.

<br /><br />

#### Concpet of layers

Concept of layers is well known and intuitive to anybody who uses keyboard. Even when just plain latin alphabet is used, it consists of 26 letters: ordinary and… next 26 capital. To reduce space occupied we have only 26 letters and **modifiers** (Shift keys) in order to get to capital letters. Additionally we have also key to permanently switch between both layers called CapsLock.

Only primary letters are accessible on "primary" layer. Contrary to that, what we see most of the time on keycaps are actually… capital letters what can be misleading, but improves readability of caycaps.

To enter capital letter we have to "switch" to "secondary" (or shifted) layer. We do it by "glueing" Shift key with letter we want to capitalize (shift from ordinary to capital), what usually is indicated by "+" sign, e.g. Shift + a = A.

The mechanism is to press Shift key down and then press down and release ordinary character and finally to release Shift key. Thanks to the springs within each key we need only to press it. Or, alternatively, switch the layer with CapsLock, press chosen character and press it again to return to primary layer. To make life easier and speed up process of pressing two keys concurrently, two Shift keys are available (Left and Right). User may use both hands to enter single diacritic character: one hand's finger presses Shift key, the second hand's finger presses chosen character. Interchangeably, to easier handle positions of keys to be entered.

So the layers are "alternatives" for entering information from keyboard to a PC.

Switching between layers:

- temporary switching with modifiers, means "for time when modifier key is down". So to enter few characters from other layer user must press down special key, actually pressing two keys (modifier + actual key); note that special key by itself do not produce any character,
- permanent switching, means "for time when other layer is active"; so to enter few characters from other layer user must just switch to that layer.

Keys used for temporary switching between layers are called **modifiers**. In terms of Microsoft Windows these are: Shift, Alt, Ctrl (aka Control) and Windows (aka Win).

For temporary switching example for Polish (programmers) keyboard layout to get diacritic character "ą" user can press down dedicated for that purpose right Alt (called AltGr), then press down additionally ("+") "a", then release "a" and release right Alt.

For permanent switching example is entering entire word in capital letters, e.g. "DIACRITIC". To enter that word user can switch to shift / capital layer by pressing dedicated key called CapsLock and then press ordinary letters: "diacritic". This key usually has in-built feature that it provides visual feedback to user informing which layer is active: if LED light is lit it means usually shift / capital layer is active.

<br /><br />

#### Concept of dead key(s)

Alternative solution coming from era of mechanical typewriters. The dead key is pressed and released before striking the key to be modified. In Microsoft Windows there is no indication to the user that a dead key has been struck, so the key appears dead (nothing immediately happens). The dead key temporarily changes the mapping of the keyboard for the next keystroke to enable diacritic character.

For example for Polish (programmers) keyboard layout to get diacritic character "ą" user can press "~" (nothing will appear on the screen = key pressing is "dead") and then "a". To get actually "~" on the screen, user has to press "~" twice, as the first pressing is "dead".

For more thorough explanation consult [Wikipedia](https://en.wikipedia.org/wiki/Dead_key).

<br /><br />

#### Concept of sticky keys

Sticky keys is attempt to use modifiers (Shift, Alt, Ctrl, Win) not in parallel (modifier "+" actual character), what is the default mechanism, but in serial (modifier, actual character). The difference is shown in the following table.

|         | default behaviour (parallel) | sticky keys (serial) |
| :------ | :--------------------------: | :------------------: |
|         |            Alt D             |        Alt D         |
|         |             a D              |        Alt U         |
|         |             a U              |         a D          |
|         |            Alt U             |         a U          |
| result: |              ą               |          ą           |

Again:

- parallel: two fingers at the same time,
- serial: even one finger at the same time.

Comment:

- sticky keys works only for modifiers,
- the mechanism works "forward" as pressing modifier forecasts that next key will be altered,
- it is possible to create mechanism which works "backward": after modifier key is pressed the previous key is converted into diacritic.

<br /><br />

#### Quality features

The following quality feastures are used to compare above mechanisms at operating system level for purpose of entering diacritic keys:

- how many keys have to be pressed to get diacritic character,
- do keys have to pressed concurrently,
- ergonomy: use of two fingers all the time
- dead key(s),
- sticky key(s) "forward",
- sticky key(s) "backward".

<br /><br />

#### Comparison of quality features provided by operating system

| quality feature                      | basic English | Polish programmers | Polish typist |
| :----------------------------------- | :-----------: | :----------------: | :-----------: |
| how many keys have to be pressed     |      n/a      |         2          |       1       |
| do keys have to pressed concurrently |      n/a      |        yes         |      no       |
| ergonomy: use of two fingers         |      n/a      |        yes         |      no       |
| dead key                             |      n/a      |        yes         |      yes      |
| sticky key "forward"                 |      n/a      |      yes (?)       |    yes (?)    |
| sticky key "backward"                |      n/a      |         no         |      no       |

? = untested by author, but plausible

<br /><br />

#### Personal

Pressing the secondary [AltGr = alternate graphic](https://en.wikipedia.org/wiki/AltGr_key) is probably the most widespread tactics, but quite problematic:

- There are two **Alt** key modfifiers on each keyboard, but for entering diacritics only the right one is used (AltGr), what for touch typist is unnatural.
- At typical keyboard it is not easy to reach any **Alt** key by any finger (nor pinky neither thumb).
- The dominant tactics says about pressing down the modifier and then, when modifier is pressed, pressing preliminary key and finally releasing modifier. As a consequence at least two fingers are involved, in parallel ("+"). As there is only one **AltGr** on the keyboard, sometimes two fingers of the same palm should be active. It has nothing to do with ergonomics.

Actually only **Shift** modifiers are ready to be pressed easily, but with the weakiest finger (pinky). The rest of modifiers are for incidental use and may even require looking into keyboard, what again has nothing to do with ergonomics.

Modifier keys are "dead" by definition. It means pressing them alone produce no character.

Taking into consideration above statements I've prepared the following tactics:

| tactics             | example user input | example user output | application name | my favorite |
| :------------------ | :----------------: | :-----------------: | :--------------: | :---------: |
| dead key            |         /a         |          ą          |    Hotstrings    |             |
| hotstring           |         a^         |          ą          |    Hotstrings    |             |
| sticky key backward |      a<Shift>      |          ą          | Shift Diacritic  |      ☑      |
| double / tripple    |         aa         |          ą          | Double Diacritic |             |

<br /><br />

#### Comparison of quality features, personal software

| quality feature                      | dead key | hotstring | sticky backward | double |
| :----------------------------------- | :------: | :-------: | :-------------: | :----: |
| how many keys have to be pressed     |    2     |     2     |        2        | 2 / 3  |
| do keys have to pressed concurrently |    no    |    no     |       no        |   no   |
| ergonomy: use of two fingers         |    no    |    no     |       no        |   no   |
| dead key                             |    no    |    no     |       no        |   no   |
| sticky key "forward"                 |   n/a    |    n/a    |       n/a       |  n/a   |
| sticky key "backward"                |   n/a    |    n/a    |       yes       |  n/a   |

<br /><br />

## Dead key (Hotstrings)

My personal modification relies on fact that dead key

- should be located in convenient area of keyboard,
- I don't mind if its pressing will be visible to user, so actually it can be "not dead".

The notion "convenient area of keyboard" means actually 4x key rows which can be easily reached without loosing contact between wrists and surface layer where keyboard is located. Taking into consideration ANSI layer and QWERTY keys layout there are actually only few good candidates: "/", "[", "]", "'". Unfortunately all of them are within reach of right pinky finger, what again (as with AltGr) destroys ergonomic symmetry. From within mentioned candidates the slash "/" seems to be the best ex equo with "'" as chances that any of them will be present within normal text are low.

The tactics can be easily realized with use of [Hotstrings](https://github.com/mslonik/Hotstrings) applcation, for whhich dedicated library [DiacriticsDeadkey_Polish.csv](https://github.com/mslonik/Hotstrings-Libraries/blob/main/DiacriticsDeadkey_Polish.csv) could be downloaded.

<br /><br />

## Hotstring (Hotstrings)

Hotstrings in form of basic letter, trigger. As a trigger always caret ("^") is aplied. For example:
a^ → ą.

This tactics can be easily realized with use of [Hotstrings](https://github.com/mslonik/Hotstrings) applcation, for whhich dedicated library [DiacriticsHotstrings.csv](https://github.com/mslonik/Hotstrings-Libraries/blob/main/DiacriticsHotstrings.csv) could be downloaded. The library uses menu to enable choice for various diacritic characters. It is useful to have such library for seldomly used diacritic characters.

<br /><br />

## Sticky key backward (Shift Diacritic)

The **Shift Diacritic** slightly modifies the tactics:

- primary keys are pressed as usual,
- as secondary keys any **Shift** key can be used (R or L) as modifiers (sticky keys),
- **Shift** modifiers (sticky keys) are just pressed and released as any other key.

Example: a{Shift} → ą

**Remark**

Thanks to the fact application runs standalone it uses its own triggerstring recognizer. It can interfere with other scripts, so order of launching could play important role. Therefore it is advised to run this application after the main Hotstrings application.

See dedicated application [Shift Diacritics]() for further details.

<br /><br />

## Double / tripple (Double Diacritic)

## Application control

### System tray icon

### Command line

### Hotstrings

### Remarks / not implemented features

# Acknowledgements
