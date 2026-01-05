local md_colors = require "md_colors"
local fmt = {}

function fmt.bold(str)
    return "<b>"..str.."</b>"
end

function fmt.italic(str)
    return "<i>"..str.."</i>"
end

function fmt.underline(str)
    return "<u>"..str.."</u>"
end

function fmt.primary(str)
    return fmt.colored(str, aio:colors().primary_text)
end

function fmt.secondary(str)
    return fmt.colored(str, aio:colors().secondary_text)
end

function fmt.colored(str, color)
    return "<font color=\""..color.."\">"..str.."</font>"
end

function fmt.bg_colored(str, color)
    return "<span style=\"background-color: "..color.."\">"..str.."</span>"
end

function fmt.red(str)
    return fmt.colored(str, md_colors.red_500)
end

function fmt.green(str)
    return fmt.colored(str, md_colors.green_500)
end

function fmt.blue(str)
    return fmt.colored(str, md_colors.blue_500)
end

function fmt.small(str)
    return "<small>"..str.."</small>"
end

function fmt.big(str)
    return "<big>"..str.."</big>"
end

function fmt.strike(str)
    return "<strike>"..str.."</strike>"
end

function fmt.space(n)
    local num = 1

    if n ~= nil and n > 1 then
        num = n
    end

    return string.rep("&nbsp;", num)
end

function fmt.escape(str)
    return (string.gsub(str, "[}{\">/<'&]", {
        ["&"] = "&amp;",
        ["<"] = "&lt;",
        [">"] = "&gt;",
        ['"'] = "&quot;",
        ["'"] = "&#39;",
        ["/"] = "&#47;"
    }))
end

return fmt
