md_colors = require "md_colors"

function on_resume()
    apps_names = { "Telegram", "WhatsApp", "Google PLay" }
    apps_pkgs = { "org.telegram.messenger.web", "com.whatsapp", "com.android.vending" } 
    apps_colors = { md_colors.light_blue_500, md_colors.green_500 }

    ui:show_buttons(apps_names, apps_colors)
end

function on_click(idx) 
    apps:launch(apps_pkgs[idx])
end
