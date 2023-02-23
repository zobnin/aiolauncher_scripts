-- name = "Script #4"
-- type = "search"

md_colors = require("md_colors")

function on_search()
    local texts = { "progress 1", "progress 2", "progress 3" }
    local progresses = { 10, 50, 90 }
    local colors = { md_colors.purple_400, md_colors.purple_600, md_colors.purple_800 }

    search:show_progress(texts, progresses, colors)
end

function on_click(idx)
    if idx == 1 then
        system:vibrate(100)
    else
        system:vibrate(300)
    end
end
