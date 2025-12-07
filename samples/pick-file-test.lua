-- name = "Files pick test"
-- description = "Test files:pick_file and files:read_uri"
-- type = "widget"
-- version = "1.0"

local MAX_PREVIEW_LEN = 300

local function escape_html(s)
    s = s:gsub("&", "&amp;")
    s = s:gsub("<", "&lt;")
    s = s:gsub(">", "&gt;")
    return s
end

local function show_initial()
    ui:show_text(
        "<b>Files pick test</b><br/>" ..
        "Tap to pick a file."
    )
end

function on_resume()
    show_initial()
end

function on_click()
    files:pick_file("*/*")
    ui:show_text(
        "<b>Files pick test</b><br/>" ..
        "Waiting for file picker..."
    )
end

function on_file_picked(uri, name)
    uri = tostring(uri or "")
    name = tostring(name or "")

    if uri == "" then
        ui:show_text(
            "<b>Files pick test</b><br/>" ..
            "<font color='red'>No URI received</font>"
        )
        return
    end

    local content = files:read_uri(uri)
    if content == nil then
        ui:show_text(
            "<b>Files pick test</b><br/>" ..
            "Picked: <b>" .. escape_html(name) .. "</b><br/>" ..
            "URI: " .. escape_html(uri) .. "<br/><br/>" ..
            "<font color='red'>files:read_uri() returned nil</font><br/>" ..
            "This may happen for binary files or if read_uri is not implemented correctly."
        )
        return
    end

    local len = #content
    local preview = content

    if len > MAX_PREVIEW_LEN then
        preview = content:sub(1, MAX_PREVIEW_LEN) .. "\n... (truncated)"
    end

    preview = escape_html(preview)

    ui:show_text(
        "<b>Files pick test</b><br/>" ..
        "Picked: <b>" .. escape_html(name) .. "</b><br/>" ..
        "URI: " .. escape_html(uri) .. "<br/>" ..
        "Length: " .. tostring(len) .. " chars<br/><br/>" ..
        "<b>Preview:</b><br/><pre>" .. preview .. "</pre>"
    )
end

