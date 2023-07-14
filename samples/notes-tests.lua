-- name = "Notes tests"
-- type = "drawer"
-- aio_version = "4.7.99"
-- author = "Evgeny Zobnin"
-- version = "1.0"
-- testing = "true"

local fmt = require "fmt"
local notes_list = {}
local test_note = {}

function on_drawer_open()
    refresh()
end

function refresh()
    notes:load()
end

function on_notes_loaded(new_notes)
    notes_list = new_notes
    local texts = map(notes_list, note_to_text)
    table.insert(texts, fmt.italic("Show new note dialog"))
    table.insert(texts, fmt.italic("Add test note"))
    table.insert(texts, fmt.italic("Change test note"))
    drawer:show_ext_list(texts)
end

function on_click(idx)
    if idx == #notes_list+1 then
        notes:show_editor()
        drawer:close()
    elseif idx == #notes_list+2 then
        notes:add{text = "test note"}
        refresh()
    elseif idx == #notes_list+3 then
        test_note.text = "test note (changed)"
        test_note.color = 1
        test_note.position = test_note.position-3
        notes:save(test_note)
        refresh()
    else
        notes:show_editor(notes_list[idx].id)
        drawer:close()
    end
end

function on_long_click(idx)
    if idx <= #notes_list then
        notes:remove(notes_list[idx].id)
        refresh()
    end
end

function note_to_text(it)
    if it.text == "test note" then
        test_note = it
    end

    if it.color ~= 6 then
        return fmt.colored(it.text, notes:colors()[it.color])
    else
        return it.text
    end
end

function map(tbl, f)
    local ret = {}
    for k,v in pairs(tbl) do
        ret[k] = f(v)
    end
    return ret
end
