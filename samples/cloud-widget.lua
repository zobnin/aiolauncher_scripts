-- name = "Cloud Widget"
-- description = "Sample script that shows how to execute script from dropbox"
-- type = "widget"
-- author = "Andrey Gavrilov"
-- version = "1.0"

local file = "script.lua"
local cloud_path = "/scripts/"..file
local local_path = "/storage/emulated/0/Android/data/ru.execbit.aiolauncher/files/scripts/"..file

cloud:get_file(cloud_path)

function on_cloud_result(res, txt)
	files:write(file, txt)
	dofile(local_path)
end
