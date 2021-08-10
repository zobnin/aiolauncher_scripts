function on_resume()
    ui:show_lines({ 
        "1 item", "2 item", "3 item" 
    })
    
    ui:prepare_context_menu({
        { "share", "Menu item 1" },
        { "copy",  "Menu item 2" },
        { "trash", "Menu item 3" },
        { "share", "Menu item 4" },
        { "copy",  "Menu item 5" },
        { "trash", "Menu item 6" },
    })
end

function on_context_menu_click(item_idx, menu_idx)
    ui:show_toast("Clicked "..menu_idx.." menu item on "..item_idx.." screen element")
end
