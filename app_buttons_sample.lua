function onResume()
    appsNames = { "Telegram", "WhatsApp", "Google PLay" }
    appsPkgs = { "org.telegram.messenger.web", "com.whatsapp", "com.android.vending" } 
    appsColors = { "#0000ff", "#00ff00" }

    ui:showButtons(appsNames, appsColors)
end

function onClick(idx) 
    system:openApp(appsPkgs[idx])
end
