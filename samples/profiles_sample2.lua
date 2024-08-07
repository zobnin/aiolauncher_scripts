-- This script shows how to dump/restore profile without saving it to the system

curr_profile = ""

function on_resume()
    ui:show_lines{
        "Dump profile",
        "Restore profile"
    }
end

function on_click(idx)
    if idx == 1 then
        curr_profile = profiles:dump_json()
        ui:show_toast("Saved")
    else
        ui:show_toast("Restoring...")
        profiles:restore_json(curr_profile)
    end
end
