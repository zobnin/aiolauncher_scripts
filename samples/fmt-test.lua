local fmt = require "fmt"

function on_resume()
    ui:show_lines{
        fmt.bold("bold"),
        fmt.italic("italic"),
        fmt.underline("underline"),
        fmt.primary("primary"),
        fmt.secondary("secondary"),
        fmt.red("red"),
        fmt.green("green"),
        fmt.blue("blue"),
        fmt.colored("lime", "#00FF00"),
        fmt.bg_colored(fmt.colored("lime background", "#000000"), "#00FF00"),
        fmt.space().."start with space",
        fmt.escape("<b>not parsed</b>"),
    }
end
