-- name = "Kodi Remote"
-- description = "Kodi multimedia center remote control widget"
-- type = "widget"
-- author = "Evgeny Zobnin (zobnin@gmail.com)"
-- arguments_help = "Enter the Kodi IP address and port in the following format: 192.168.0.102:8080"
-- version = "1.0"

local colors = require "md_colors"
local json = require "json"

-- constants

local media_type = "application/json"

local get_players_cmd = [[ { "id": 1, "jsonrpc": "2.0", "method": "Player.GetActivePlayers" } ]]
local play_cmd = [[ {"jsonrpc": "2.0", "method": "Player.PlayPause", "params": { "playerid": XXX }, "id": 1} ]]
local prev_cmd = [[ {"jsonrpc": "2.0", "method": "Player.GoTo", "params": {"playerid": XXX,"to":"previous"}, "id":1} ]]
local next_cmd = [[ {"jsonrpc": "2.0", "method": "Player.GoTo", "params": {"playerid": XXX,"to":"next"}, "id":1} ]]

local buttons = { "Prev", "Pause", "Next", "Open Kore" }
local buttons_colors = { colors.blue_600, colors.blue_600, colors.blue_600, colors.blue_900 }
local buttons_cmds = { prev_cmd, play_cmd, next_cmd }

-- global vars

local url = nil
local curr_idx = nil

function on_resume()
    if next(aio:get_args()) == nil then
        ui:show_text("Tap to enter Kodi address")
        return
    end
    
    local ip_port = aio:get_args()[1]:split(":")
    url = "http://"..ip_port[1]..":"..ip_port[2].."/jsonrpc"

    ui:show_buttons(buttons, buttons_colors)
end

function on_click(idx)
    if next(aio:get_args()) == nil then
        aio:show_args_dialog()
        return
    end

    if (idx == 4) then
        apps:launch("org.xbmc.kore")
        return
    end

    curr_idx = idx
    http:post(url, get_players_cmd, media_type, "players")
end

function on_network_result_players(result)
    local parsed = json.decode(result)

    if parsed.error ~= nil then
        show_error(parsed)
        return
    end

    local player_id = parsed.result[1].playerid
    local cmd = buttons_cmds[curr_idx]:replace("XXX", player_id)

    http:post(url, cmd, media_type, "cmd")

    curr_idx = nil
end

function on_network_result_cmd(result)
    local parsed = json.decode(result)
    
    if parsed.error ~= nil then
        show_error(parsed)
    end
end

-- utils

function show_error(parsed)
    ui:show_toast("Error "..parsed.error.code..": "..parsed.error.message)
end

