name = "GitHub Trending"
description = "GitHub trending repositories (trending-github.com)"
scriptType = "widget"
author = "Evgeny Zobnin (zobnin@gmail.com)"
version = "1.0"

function onAlarm()
    net:getText("https://api.trending-github.com/github/repositories") 
end

function onNetworkResult(result)
    local names = {
        json:getValue(result, "array object:0 string:name"),
        json:getValue(result, "array object:1 string:name"),
        json:getValue(result, "array object:2 string:name"),
    }
    
    local descriptions = {
        json:getValue(result, "array object:0 string:description"),
        json:getValue(result, "array object:1 string:description"),
        json:getValue(result, "array object:2 string:description"),
    }
    
    urls = {
        json:getValue(result, "array object:0 string:url"),
        json:getValue(result, "array object:1 string:url"),
        json:getValue(result, "array object:2 string:url"),
    }

    aio:showLinesWithAuthors(names, descriptions)
end

function onClick(idx)
    aio:openBrowser(urls[idx])
end
