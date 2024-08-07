-- This sample lists current system profiles and allows to restore any of it

profs = {}

function on_resume()
    profs = profiles:list()
    ui:show_lines(profiles:list())
end

function on_click(idx)
    ui:show_toast("Restoring...")
    profiles:restore(profs[idx])
end
