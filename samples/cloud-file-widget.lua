-- name = "File Explorer"
-- description = "Dropbox file explorer. Shows only AIO Launcher subdirectory"
-- type = "widget"
-- version = "1.0"
-- author = "Andrey Gavrilov"
-- aio_version = "4.0.9"

local path,file,text = "","",""
local name = "home"
local paths,names,is_dirs,tab = {},{},{},{}

function on_alarm()
	cloud:list_dir(path,"list")
end

function on_resume()
    ui:show_lines(tab)
end

function on_cloud_result_list(res)
    paths,names,is_dirs,tab = {},{},{},{}
	if path == "" then
	    table.insert(tab,"&#x1f503 <b>"..name.."</b>")
	else
		table.insert(tab,"&#x2b06&#xfe0f <b>"..name.."</b>")
    end
	table.insert(paths,path)
	table.insert(names,name)
	table.insert(is_dirs,true)
    if type(res) == "table" then
        for i,v in ipairs(res) do
            table.insert(paths,v.path)
            table.insert(names,v.name)
            table.insert(is_dirs,v.is_dir)
            if v.is_dir then
                table.insert(tab,"&#x1f4c1 "..v.name)
            else
                table.insert(tab,"&#x1f4c4 "..v.name)
            end
        end
    end
    ui:show_lines(tab)
end

function on_cloud_result_file(res,txt)
    text = txt
    ui:show_dialog(file,txt:gsub("\n","<br>"),"Cancel","Share")
end

function on_click(idx)
    system:vibrate(10)
	if idx == 1 then
		local t = path:split("/")
		path = ""
		name = "home"
		for i = 1,#t-1 do
			path = path.."/"..t[i]
			name = t[i]:gsub("/","")
		end
		cloud:list_dir(path,"list")
	else
		if is_dirs[idx] then
			path = paths[idx]
			name = names[idx]
			cloud:list_dir(paths[idx],"list")
		else
		    file = names[idx]
			cloud:get_file(paths[idx],"file")
		end
	end
end

function on_dialog_action(idx)
    if idx == 2 then
        system:share_text(text)
    end
end
