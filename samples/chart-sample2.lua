local api_url = "https://api.covid19api.com/country/ru?from=2021-07-01T00:00:00Z&to=2021-07-31T00:00:00Z"

local tab = {}

function on_alarm()
    http:get(api_url)
end

function on_network_result(result)
    tab = get_tab_ajson(result)
    ui:show_chart("Covid", tab, "x:date y:number")
end

function totime(str)
    local y,m,d = str:match("(%d+)-(%d+)-(%d+)")
    return os.time{year=y, month=m, day=d}*1000
end

function get_tab_ajson(result)
    local tab = {}
    local dat = ajson:get_value(result, "array object:0 string:Date")
    local conf = ajson:get_value(result, "array object:0 int:Confirmed")
    local prev_conf = conf
    local new = conf - prev_conf
    tab[1] = {totime(dat), new}
    local i = 1
    while true do
        dat = ajson:get_value(result, "array object:"..i.." string:Date")
        if dat:match("Error") == "Error" then
            break
        end
        conf = ajson:get_value(result, "array object:"..i.." int:Confirmed")
        new = conf - prev_conf
        prev_conf = conf
        tab[i] = {totime(dat), new}
        i = i+1
    end
    return tab
end
