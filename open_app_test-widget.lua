function onResume()
    ui:showText("Click to open Google Play")
end

function onClick()
    system:openApp("com.android.vending")
end
