local fmt = require "fmt"

function on_resume()
    ui:show_lines{
        "Tap to change text",
        "Tap to change text quick",
        "Tap to change text color",
        "Tap to change text and back",
        "Tap to typewriter",
        "Tap to karaoke",
        "Tap to blink",
        "Tap to move",
        "Tap to heartbeat",
        "Tap to shake",
    }
end

function on_click(idx)
    if idx == 1 then
        morph:change_text(idx, "Text changed")
    elseif idx == 2 then
        morph:change_text(idx, "Text changed", 0)
    elseif idx == 3 then
        morph:change_text(idx, fmt.red("Color changed"))
    elseif idx == 4 then
        morph:change_text(idx, "Text changed")
        morph:run_with_delay(1000, function ()
            morph:change_text(idx, "Type to change text and back")
        end)
    elseif idx == 5 then
        local tab = {}
        local text = "Wake up, Neo"
        for i=1,text:len() do
            table.insert(tab, fmt.green(text:sub(1, i)))
        end
        morph:change_text_seq(idx, tab, 100)
    elseif idx == 6 then
        local tab = {}
        local text = [[
            Yesterday
            All my troubles seemed so far away
            Now it looks as though they're here to stay
            Oh, I believe in yesterday
        ]]
        for i=1,text:len() do
            table.insert(tab, fmt.blue(text:sub(1, i))..text:sub(i+1))
        end
        morph:change_text_seq(idx, tab, 100)
    elseif idx == 7 then
        anim:blink(idx)
    elseif idx == 8 then
        anim:move(idx, 100, 0)
    elseif idx == 9 then
        anim:heartbeat(idx)
    elseif idx == 10 then
        anim:shake(idx)
    end
end
