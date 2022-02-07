
local curr_notab = {}
local curr_titletab = {}
local curr_keystab = {}

function on_notify_posted(n)
    curr_notab[n.key] = n
    redraw()
end

function on_notify_removed(n)
    curr_notab[n.key] = nil
    redraw()
    ui:show_toast("Notify from "..n.package.." removed")
end

function redraw()
    fill_tabs(curr_notab)
    ui:show_lines(curr_titletab)
end

function on_click(i)
    notify:open(curr_keystab[i])
end

function fill_tabs(tab)
    curr_titletab = {}
    curr_keystab = {}

    for k,v in pairs(tab) do
        table.insert(curr_titletab, v.title)
        table.insert(curr_keystab, v.key)
    end
end
