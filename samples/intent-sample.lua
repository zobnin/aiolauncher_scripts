function on_resume()
    ui:show_lines{
        "open browser",
        "open market",
        "open google feed",
        "open player",
        "send broadcast to launcher (open apps menu)",
    }
end

function on_click(idx)
    if idx == 1 then
        intent:start_activity{
            action = "android.intent.action.VIEW",
            data = "https://aiolauncher.app",
        }
    elseif idx == 2 then
        intent:start_activity{
            action = "android.intent.action.MAIN",
            category = "android.intent.category.APP_MARKET",
        }
    elseif idx == 3 then
        intent:start_activity{
            action = "com.google.android.googlequicksearchbox.GOOGLE_SEARCH",
            extras = {
                query = "AIO Launcher",
            },
        }
    elseif idx == 4 then
        intent:start_activity{
            action = "android.intent.action.VIEW",
            category = "android.intent.category.DEFAULT",
            data = "file:///system/product/media/audio/ringtones/Atria.ogg",
            type = "audio/ogg",
    }
    else
        intent:send_broadcast{
            action = "ru.execbit.aiolauncher.COMMAND",
            extras = {
                cmd = "apps_menu",
            },
        }
    end
end
