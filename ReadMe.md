# What are Polish diacritic (accented) characters?

These are characters which are present only in Polish language:

``
ą, ć, ę, ł, ó, ś, ź, ż
``
and capital letters.

# How this script works
Run it. When you want to get Polish diacritic (accented) character e.g. in word "ćma" after pressing "c" press whichever "Shift" key:

``
c
{Right Shift Down}
{Right Shift up}
m
a
``

# Rationale
Usually (under Microsoft Windows) Polish diacritic (accented) characters are entered with use of "Polish programmer" local setting. Then to get such letter before such character press down "Right Alt" or "AltGr" keyboard key and release it afterwards.

Referring to the above example, to get word "ćma" one have to press:

``
{Right Alt Down}
c
{Right Alt Up}
m
a
``

# Comparison of traits  between this script and default (old) solution:
``Down`` = ``D``

``Up`` = ``U``

``{Left Shift}`` = ``{LShift}``, ``{Left Alt}`` = ``{LAlt}``

``{Right Shift}`` = ``{RShift}``, ``{Right Alt}`` = ``{RAlt}``

e.g. ``{Left Shift Down}`` = ``{LShiftD}``


| Trait | Default | PolishDiacritics | Comment |
| :---: | :--- | :---: | :--- |
| Entering capital letters | ``{LShiftD}c{LShiftU}`` → ``C``<br /> or <br /> ``{RShiftD}c{RShiftU}``→ ``C`` | The same as default. | No extra benefit. |
| Entering Polish diacritic characters | ``{RAltD}c{RAltU}`` → ``ć`` | ``c{LShiftD}{LShiftU}`` → ``ć`` <br /> or <br /> ``c{RShiftD}{RShiftU}`` → ``ć``| - One can use the same {Shift} keys to enter diacritic characters and capital characters. <br /> - Whichever {Shift} key be used to enter whichever diacritic character. <br /> - 

Downsides of this approach:
- Always "Right Alt" have to be pressed, no matter where on keyboard diacritic is located.

- "Right Alt" is reserved for the purpose of entering Polish diacritics (cannot be used for any other purpose and no longer works as modifier). "Left Alt" is used as ordinary "Alt" key just as modifier.

- "Right Alt" usually is pressed by right thumb what is far from ergonomic.