function onResume()
    ui:showButtons({ "Show drawer" })
end

function onClick()
    system:aioAction("apps_menu")
end
