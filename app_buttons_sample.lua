function onResume()
    appsNames = { "Telegram", "WhatsApp", "Google PLay" }
    appsPkgs = { "org.telegram.messenger.web", "com.whatsapp", "com.android.vending" } 

    ui:showButtons(appsNames)
end

function onClick(idx) 
    system:openApp(appsPkgs[idx])
end
