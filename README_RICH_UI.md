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

The first command displays the line "First line", the "new\_line" command moves to a new line, adding a space equal to one unit (each unit is 4 pixels). Then, the "text" command adds a new line, followed by a move to a new line and the display of two buttons. Since there is no "new\_line" command between the button display commands, they will be displayed in one line, one after the other, from left to right with a gap of 2 units. The "spacer" command is responsible for the horizontal gap.

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
3. `Gravity` values can be combined, for example, to display a text element in the top right corner of the current line, you can specify `gravity = "top|right"`.

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

Handling clicks on elements works the same as when using the `ui` module API: define `on_click(index)` and `on_long_click(index)`. The index is the element's 1-based position in the definition, **including `new_line` and `spacer` commands**. Raw `gui` elements do not accept inline `tap` or `long_tap` callbacks. See [rich-gui-sample.lua](samples/rich-gui-sample.lua) and [rich-gui-media-sample.lua](samples/rich-gui-media-sample.lua).

By default, clicks and long clicks apply to the individual element that was pressed. If an element represents the whole current row, add `row = true` to its options. This makes empty space in that row clickable too, and when a long click opens a context menu, the whole row is highlighted instead of only the element:

```
{"icon", "fa:file", {row = true}},
{"text", "Document.txt"},
```

If several elements in the same line use `row = true`, the empty row area uses the first such element's click handler. Pressing a later element directly still calls that element's own handler.

## Images and charts

`image` and `chart` elements can share one `gui` definition with text, icons, progress bars, and buttons. Render the complete definition once; calling `ui:show_image()`, `ui:show_chart()`, or another content renderer afterward replaces it. Toasts and context menus do not replace the widget content.

These elements require an AIO Launcher build with `ui.builder_image` and `ui.builder_chart`. The [media sample](samples/rich-gui-media-sample.lua) checks availability before rendering.

```lua
local points = {{1, 12}, {2, 18}, {3, 15}}
local layout = gui{
    {"image", "https://dummyimage.com/160x200/334455/ffffff", {
        width = 80, height = 100, scale = "crop",
    }},
    {"spacer", 2},
    {"image", "https://dummyimage.com/160x200/665544/ffffff", {
        width = 80, height = 100, scale = "fit",
    }},
    {"new_line"},
    {"chart", points, {height = 150, format = "x:number y:number"}},
    {"new_line"},
    {"button", "Refresh"},
}
layout.render()
-- on_click(1) and on_click(3): images; on_click(5): chart; on_click(7): button.
```

* `{"image", uri, options}` accepts an image URL or URI, using the same loader as `ui:show_image`. `scale` is `"fit"` by default (show the whole image) or `"crop"` (fill the box and crop the edges). A failed image load leaves an empty box while the other elements remain available. AIO icon ids such as `ref:contact:...` belong in an `icon` element, not in the image URI.
* `{"chart", points, options}` accepts numeric coordinate pairs such as `{{1, 12}, {2, 18}}`. Convert named data records to pairs first. Options include `format`, rich-text `title`, `show_grid`, and rich-text `copyright`, with the same meanings as in `ui:show_chart`.
* Both accept `width` and `height` in **dp**. Width must be non-negative; the default `0` shares the remaining row width with other flexible media elements. Set a positive width for covers or avatars. Height defaults to `150` and must be positive; unlike standalone `ui:show_image(uri, 0)`, layout images do not have an automatic-height mode.
* Both support `gravity`, `margin`, `offset`, and `row`. Use `on_click(index)` and `on_long_click(index)` for actions. `spacer` widths use 4dp units, so `{"spacer", 2}` is an 8dp gap, while an image's `width = 80` means 80dp.

Chart axis formats are `number`, `float`, `date`, `time`, and `none`. Write tokens without spaces after colons, for example `"x:time y:float"`. Date/time axes take Unix **milliseconds**: multiply Unix seconds by 1000 when building points.

## Sliders

A `slider` element adds a draggable integer slider that takes the whole line. Its text is an optional rich-text label shown on the left; with an empty label the slider uses the full width. Options are `value`, `min` (default `0`), `max` (default `100`), and `margin`.

This element requires an AIO Launcher build with `ui.builder_slider` (version 7.6.1 or newer).

```lua
local brightness = 40
local volume = 7

local function render()
    gui{
        {"text", "<b>Levels</b>"},
        {"new_line", 1},
        {"slider", "Brightness", {value = brightness}},
        {"new_line"},
        {"slider", "Volume", {value = volume, min = 0, max = 15}},
    }.render()
end

function on_resume()
    render()
end

-- index is the slider's position in the definition: 3 for brightness, 5 for volume.
function on_slider_change(index, value)
    if index == 3 then
        brightness = value
    elseif index == 5 then
        volume = value
    end
    render()
end
```

Sliders do not call `on_click` or `on_long_click`. `on_slider_change(index, value)` is called once, when the user releases the slider. Keep the value in script state and render it back, so the next render does not reset the slider.

Another useful option when working with text is the `font_padding` parameter. By default, Android fonts include invisible space above and below the letters. If you want to make lines more compact and collapse them closer to each other, you can disable this padding:

```
{"text", "Compact text", {font_padding = false}}
```

To control spacing between elements, there is the `margin` parameter. It allows you to set external spacing around an element, using a familiar CSS-like shorthand. For example, `"10dp"` will add 10dp to all sides, `"10dp 20dp"` will set 10dp top and bottom and 20dp left and right, `"5dp 10dp 15dp"` will set 5dp top, 10dp left and right, and 15dp bottom, and `"1dp 2dp 3dp 4dp"` will set each side individually (top, right, bottom, left). You can also use units like `dp`, `px`, `sp`, `em` (relative to element size), or `%` (of element size). Negative values are supported, which makes it possible to overlap elements:

```
{"text", "Title", {size = 32, margin = "-0.5em 0"}}
```

And if you want to shift an element slightly without affecting the layout around it, you can use the `offset` parameter. It moves the element visually along the X and Y axes. This is useful for fine-tuning the position of icons or labels. The format is `"dx dy"` (or `"dx,dy"`), with the same units as in `margin`:

```
{"icon", "fa:star", {size = 32, offset = "2dp -1dp"}}
```

With these additional options — `font_padding`, `margin` and `offset` — you can achieve precise control over typography, spacing, and positioning, making your custom UI look as polished as the built-in widgets.

The supported elements and their defaults are shown below. An omitted text size follows the theme; an omitted bitmap icon size preserves its intrinsic dimensions (up to 1200 pixels on the longest side). Set a positive `size` to override these defaults.

```
{"text", "", {size = -1, color = "", gravity = "left", font_padding = true, margin = "0", offset = "0", row = false}},
{"button", "", {color = "", gravity = "left", expand = false, margin = "0", offset = "0", row = false}},
{"icon", "", {size = -1, color = "", gravity = "left", margin = "0", offset = "0", fixed_width = false, row = false}},
{"progress", "", {progress = 0, color = "", margin = "0", offset = "0", row = false}},
{"slider", "", {value = 0, min = 0, max = 100, margin = "0"}},
{"image", "", {width = 0, height = 150, scale = "fit", gravity = "left", margin = "0", offset = "0", row = false}},
{"chart", {}, {width = 0, height = 150, format = "", title = "", show_grid = false, copyright = "", gravity = "left", margin = "0", offset = "0", row = false}},
{"new_line", 0},
{"spacer", 0},
```
