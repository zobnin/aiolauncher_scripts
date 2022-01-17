-- name = "Script #2"
-- type = "search"

md_colors = require("md_colors")

function on_search()
    local texts = { "text1", "text2", "text3" }
    local colors = { md_colors.purple_400, md_colors.purple_600, md_colors.purple_800 }

    search:show(texts, colors)
end

function on_click(idx)
    if idx == 1 then
        system:vibrate(100)
    else
        system:vibrate(300)
    end
end
