-- name = "Profiles auto dumper"
-- description = "Hidden widget that auto dump profile on every return to the home screen"
-- type = "widget"
-- author = "Evgeny Zobnin (zobnin@gmail.com)"
-- version = "1.0"
-- foldable = "false"

local prof_name = "Auto dumped"

function on_load()
    ui:hide_widget()
end

function on_resume()
    profiles:dump(prof_name)
end
