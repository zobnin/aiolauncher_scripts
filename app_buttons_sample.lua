function on_resume()
    apps_names = { "Telegram", "WhatsApp", "Google PLay" }
    apps_pkgs = { "org.telegram.messenger.web", "com.whatsapp", "com.android.vending" } 
    apps_colors = { "#0000ff", "#00ff00" }

    ui:show_buttons(apps_names, apps_colors)
end

function on_click(idx) 
    system:open_app(apps_pkgs[idx])
end
