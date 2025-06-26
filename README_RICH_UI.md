Starting with version 5.2.1, AIO Launcher includes an API that allows for displaying a more complex interface than what the high-level functions of the `ui` module allowed. For example, you can display text of any size, center it, move it up and down, display buttons on the left and right sides of the screen, draw icons of different sizes, and much more. Essentially, you can replicate the appearance of any built-in AIO widget.

Open the example [rich-gui-basic-sample.lua](samples/rich-gui-basic-sample.lua) and study it. As you can see, the new API consists of just one function `gui`, which takes a table describing the UI as input and returns an object that has a `render()` method for drawing this UI.

The UI is built line by line, using commands that add elements from left to right, with the possibility of moving to a new line. The provided example displays two lines, under which are two buttons:

```
{"text", "First line"},
{"new_line", 1},
{"text", "Second line"},
{"new_line", 2},
{"button", "Button #1"},
{"spacer", 2},
{"button", "Button #2"},
```

The first command displays the line "First line", the "new_line" command moves to a new line, adding a space equal to one unit (each unit is 4 pixels). Then, the "text" command adds a new line, followed by a move to a new line and the display of two buttons. Since there is no "new_line" command between the button display commands, they will be displayed in one line, one after the other, from left to right with a gap of 2 units. The "spacer" command is responsible for the horizontal gap.

This example is already useful, but it's too plain. Let's add some colors and vary the text lines a bit: make the first line larger, and write the second line in italic font. Also, let's work on the color of the buttons:

```
{"text", "First line", {size = 21}},
{"new_line", 1},
{"text", "<i>Second line</i>"},
{"new_line", 2},
{"button", "Button #1", {color = "#ff0000"}},
{"spacer", 2},
{"button", "Button #2", {color = "#0000ff"}},
```

To change the size of the text, we used the table `{size = 21}`. This is the standard approach if a command has more than one parameter, then all other arguments are passed in the table. To make the text italic, we used the HTML tag `<i>`. The "text" command supports many tags for text transformation. The color of the buttons is also changed using a table.

It's more interesting now, but again, an interface where all elements are grouped on the left side may not always be suitable. We need a way to align elements on the right side of the screen or in the center. Let's make the first line be in the middle of the line (kind of like a title), and the second button - on the right side:

```
{"text", "First line", {size = 21, gravity = "center_h"}},
{"new_line", 1},
{"text", "<i>Second line</i>"},
{"new_line", 2},
{"button", "Button #1", {color = "#ff0000"}},
{"spacer", 2},
{"button", "Button #2", {color = "#0000ff", gravity = "right"}},
```

Here we used the `gravity` parameter to change the location of the element in the line. Three things are important to know about `gravity`:

1. It changes the position of the element only within the current line;
2. Possible `gravity` values: `left`, `top`, `right`, `bottom`, `center_h` (horizontal centering), `center_v` (vertical centering) and `anchor_prev`;
3. `Gravity` values can be combined, for example, to display a text element in the top right corner of the current line, you can specify `gravity = "top|right"`;

Also, there are two limitations to know about:

1. The `center_h` value is applied to each element separately, meaning if you add two lines with the gravity value `center_h` in one line, they will not both be grouped and displayed in the center, but instead, they will split the screen in half and be displayed each in the center of its half. This situation can be rectified by using the `anchor_prev` as the value for gravity. This flag anchors the current element to the previous element of the current line, so that the `gravity` value of the previous element starts affecting both elements.
2. The `right` value affects not only the element to which it is applied but also all subsequent elements in the current line. That means if you add another button after "Button #2", it will also be on the right side after "Button #2".

Surely you will want to add icons to your UI. There are several ways to do this. The first way is to embed the icon directly into the text, in this case, you can use any icon from the FontAwesome set:

```
{"text", "This is icon: %%fa:microphone%%"}
```

The second way: use the icon command (in this case, you can also specify the size and color of the icon):

```
{"icon", "fa:microphone", {size = 32, color = "#ff0000"}}
```

Third way: display icon in the button:

```
{"button", "fa:microphone"}
{"button", "Text with icon: %%fa:microphone%%"}
```

The second method also allows displaying icons of applications and contacts. How to do this is shown in the example [rich-gui-sample.lua](samples/rich-gui-sample.lua). You can also use the `icon` element to display your own icons in SVG format. Example: [svg-sample.lua](samples/svg-sample.lua).

By the way, if you want the button to stretch across the entire width of the screen, you can use the expand argument:

```
{"button", "Full with button", {expand = true}}
```

Handling clicks on elements works the same as when using the `ui` module API. Just define `on_click()` or `on_long_click()` functions. The first parameter of the function will be the index of the element. How to use this mechanism can be learned in the example [samples/rich-ui-sample.lua].

This is all you need to know about the new API. Below is an example demonstrating all supported elements and all their default parameters:

```
{"text", "", {size = 17, color = "", gravity = "left"}},
{"button", "", {color = "", gravity = "left", expand = "false"}},
{"icon", "", {size = 17, color = "", gravity = "left"}},
{"progress", "", {progress = 0, color = ""}},
{"new_line", 0},
{"spacer", 0},
```
