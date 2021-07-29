function onResume()
    local yearDays = 365
    local currentDay = os.date("*t").yday
    local percent = math.floor(currentDay / (yearDays / 100))
    aio:showProgressBar("Year progress: "..percent.."%", currentDay, yearDays)
end
