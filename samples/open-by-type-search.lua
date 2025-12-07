local last_url

function on_search(query)
    if not query:match("^https?://") then
        return
    end

    last_url = query
    http:get(query, "open_url")
end

function on_network_result_open_url(body, code, headers)
    if not last_url or not headers then return end

    local ct = headers["content-type"] or ""
    local url = headers["location"] or last_url

    if ct:find("^image/") then
        intent:start_activity{
            action = "android.intent.action.VIEW",
            data   = url,
            type   = "image/*",
        }
    elseif ct:find("^audio/") then
        intent:start_activity{
            action = "android.intent.action.VIEW",
            data   = url,
            type   = "audio/*",
        }
    elseif ct:find("^video/") then
        intent:start_activity{
            action = "android.intent.action.VIEW",
            data   = url,
            type   = "video/*",
        }
    else
        system:open_browser(url)
    end
end

