-- name = "ChatGPT"
-- description = "A search script that allows you to task with ChatGPT"
-- data_source = "openai.com"
-- type = "search"
-- author = "Evgeny Zobnin"
-- version = "1.0"

local json = require "json"

-- constants
local ok_color = aio:colors().primary_text
local error_color = aio:colors().progress_bad
local uri = "https://ai.fakeopen.com/v1/chat/completions"
local key = "pk-this-is-a-real-free-pool-token-for-everyone"

-- vars
local question = ""
local answer = ""

local payload_template = [[
{
    "model": "gpt-3.5-turbo",
    "temperature": 0.8,
    "max_tokens": 100,
    "messages": [
        {
            "role": "user",
            "content": "%%Q%%. Answer in one sentence."
        }
    ]
}
]]

function on_search(input)
    search:show_lines({"Ask ChatGPT: \""..input.."\""}, {ok_color}, true)
    question = input
    answer = ""
end

function on_click()
    if answer == "" then
        search:show_lines({"Waiting for answer..."}, {ok_color}, true)
        make_request(question)
        return false
    else
        system:copy_to_clipboard(answer)
        return true
    end
end

function make_request(str)
    local payload = payload_template:replace("%%Q%%", str)

    http:set_headers{ "Authorization: Bearer "..key }
    http:post(uri, payload, "application/json")
end

function on_network_result(result, code)
    if code >= 200 and code < 300 then
        answer = get_answer(result)
        search:show_lines({answer}, {ok_color}, true)
    else
        search:show_lines({"Server error: "..code}, {error_color}, true)
    end
end

function get_answer(result)
    local t = json.decode(result)
    return t.choices[1].message.content
end
