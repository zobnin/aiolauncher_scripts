local xml = require "xml"

local test_xml = 
[[
<test one="two">
    <three four="five" four="six"/>
    <three>eight</three>
    <nine ten="eleven">twelve</nine>
</test>
]]

function on_resume()
    local parsed = xml:parse(test_xml)

    ui:show_text(parsed.test["@one"])
end
