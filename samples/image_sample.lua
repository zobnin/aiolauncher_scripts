local height = 0

function on_load()
    show_image()
end

function on_click()
    if height == 0 then
        height = 100
    else
        height = 0
    end
    show_image()
end

function show_image()
    ui:show_image("https://dummyimage.com/600x400/000/fff", height)
end
