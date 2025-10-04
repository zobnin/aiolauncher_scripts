-- name = "Курсы валют ЦБ"
-- description = "Виджет отображает курсы валют Центрального Банка России"
-- data_source = "https://www.cbr.ru/"
-- type = "widget"
-- lang = "ru"
-- author = "Andrey Gavrilov"
-- version = "1.0"

local cur = "USD"
local base_cur = "RUB"
local nominal = 1
local cur_id = "R01235"
local idx = 0
local history = ""

function on_alarm()
    get_rates()
end

function on_click()
    http:get("https://www.cbr.ru/scripts/XML_daily.asp","today")
end

function on_long_click()
    if history == "" then
        return
    end
    dialogs:show_dialog("История курсов ЦБ\n"..nominal.." "..cur.." / "..base_cur,history)
end

function on_settings()
    local xml = require "xml"
    local t = xml:parse(currencies)
    local names = {}
    for i,v in ipairs(t.Valuta.Item) do
        table.insert(names,v.Name:value())
        if v["@ID"] == cur_id then
            idx = i
        end
    end
    dialogs:show_radio_dialog("Выберите валюту",names,idx)
end

function on_dialog_action(data)
    if data == -1 then
        return
    end
    local xml = require "xml"
    local t = xml:parse(currencies)
    cur = t.Valuta.Item[data].ISO_Char_Code:value()
    cur_id = t.Valuta.Item[data]["@ID"]
    idx = data
    get_rates()
end

function on_network_result_today(result,error)
    local xml = require "xml"
    local t = xml:parse(result)
	local today = ""
	local date_today = t.ValCurs["@Date"]
	for i,v in ipairs(t.ValCurs.Valute) do
		if i>1 then
			today = today.."<br>"
		end
		today = today..v.Nominal:value().." "..v.CharCode:value().." = "..v.Value:value():replace(",",".").." "..base_cur
	end
	dialogs:show_dialog("Курсы валют ЦБ\n"..date_today,today)
end

function on_network_result_history(result,error)
    history = ""
    local color = aio:colors()
    local equals = "<font color=\""..color.secondary_text.."\"> = </font>"
    local xml = require "xml"
    local t = xml:parse(result)
    if t.ValCurs.Record == nil then
        ui:show_text("Для валюты "..cur.." не заданы курсы")
        return
    end
	local points = {}
	local k=#t.ValCurs.Record
	local dd = t.ValCurs.Record[1]["@Date"]:split(".")
	nominal = t.ValCurs.Record[k].Nominal:value()
	local tp = os.time{day=dd[1],month=dd[2],year=dd[3]} - 24*60*60
	for i,v in ipairs(t.ValCurs.Record) do
		dd = v["@Date"]:split(".")
		local tm = os.time{day=dd[1],month=dd[2],year=dd[3]}
	    for tt=tp+24*60*60, tm, 24*60*60 do
		    local point = {}
		    table.insert(point,tt*1000)
		    table.insert(point,v.Value:value():replace(",",".")/v.Nominal:value()*nominal)
		    table.insert(points,point)
	    end
	    tp = tm
		history = v["@Date"]..": "..nominal.." "..cur.." = "..v.Value:value():replace(",",".")/v.Nominal:value()*nominal.." "..base_cur..history
		if i<#t.ValCurs.Record then
		    history = "<br>"..history
		end
	end
	local ch = round((t.ValCurs.Record[k].Value:value():replace(",",".")/t.ValCurs.Record[k].Nominal:value()*nominal-t.ValCurs.Record[k-1].Value:value():replace(",",".")/t.ValCurs.Record[k-1].Nominal:value()*nominal)/t.ValCurs.Record[k-1].Value:value():replace(",",".")*t.ValCurs.Record[k-1].Nominal:value()/nominal*100,2)
	ui:show_chart(points,"x:date y:number",t.ValCurs.Record[k].Value:value():replace(",",".")/t.ValCurs.Record[k].Nominal:value()*nominal.." "..base_cur,true)
end

function get_rates()
    local date2 = os.date("%d/%m/%Y")
    local dd = date2:split("/")
    local t = os.time{day=dd[1],month=dd[2],year=dd[3]}-30*24*60*60
	local date1 = os.date("%d/%m/%Y",t)
	local str = "https://www.cbr.ru/scripts/XML_dynamic.asp?date_req1="..date1.."&date_req2="..date2.."&VAL_NM_RQ="..cur_id
    http:get(str,"history")
end

function get_formatted_change_text(change)
	local color = aio:colors()
    if change > 0 then
        return "<font color=\""..color.progress_good.."\">&nbsp+"..change.."%</font>"
    elseif change < 0 then
        return "<font color=\""..color.progress_bad.."\">&nbsp"..change.."%</font>"
    else
        return "<font color=\""..color.secondary_text.."\">&nbsp"..change.."%</font>"
    end
end

currencies = [[
<?xml version="1.0" encoding="windows-1251"?>
<Valuta name="Foreign Currency Market Lib">
<Item ID="R01010">
<Name>Австралийский доллар</Name>
<EngName>Australian Dollar</EngName>
<Nominal>1</Nominal>
<ParentCode>R01010 </ParentCode>
<ISO_Num_Code>36</ISO_Num_Code>
<ISO_Char_Code>AUD</ISO_Char_Code>
</Item>
<Item ID="R01020A">
<Name>Азербайджанский манат</Name>
<EngName>Azerbaijan Manat</EngName>
<Nominal>1</Nominal>
<ParentCode>R01020 </ParentCode>
<ISO_Num_Code>944</ISO_Num_Code>
<ISO_Char_Code>AZN</ISO_Char_Code>
</Item>
<Item ID="R01035">
<Name>Фунт стерлингов Соединенного королевства</Name>
<EngName>British Pound Sterling</EngName>
<Nominal>1</Nominal>
<ParentCode>R01035 </ParentCode>
<ISO_Num_Code>826</ISO_Num_Code>
<ISO_Char_Code>GBP</ISO_Char_Code>
</Item>
<Item ID="R01060">
<Name>Армянский драм</Name>
<EngName>Armenia Dram</EngName>
<Nominal>1000</Nominal>
<ParentCode>R01060 </ParentCode>
<ISO_Num_Code>51</ISO_Num_Code>
<ISO_Char_Code>AMD</ISO_Char_Code>
</Item>
<Item ID="R01090B">
<Name>Белорусский рубль</Name>
<EngName>Belarussian Ruble</EngName>
<Nominal>1</Nominal>
<ParentCode>R01090 </ParentCode>
<ISO_Num_Code>933</ISO_Num_Code>
<ISO_Char_Code>BYN</ISO_Char_Code>
</Item>
<Item ID="R01100">
<Name>Болгарский лев</Name>
<EngName>Bulgarian lev</EngName>
<Nominal>1</Nominal>
<ParentCode>R01100 </ParentCode>
<ISO_Num_Code>975</ISO_Num_Code>
<ISO_Char_Code>BGN</ISO_Char_Code>
</Item>
<Item ID="R01115">
<Name>Бразильский реал</Name>
<EngName>Brazil Real</EngName>
<Nominal>1</Nominal>
<ParentCode>R01115 </ParentCode>
<ISO_Num_Code>986</ISO_Num_Code>
<ISO_Char_Code>BRL</ISO_Char_Code>
</Item>
<Item ID="R01135">
<Name>Венгерский форинт</Name>
<EngName>Hungarian Forint</EngName>
<Nominal>100</Nominal>
<ParentCode>R01135 </ParentCode>
<ISO_Num_Code>348</ISO_Num_Code>
<ISO_Char_Code>HUF</ISO_Char_Code>
</Item>
<Item ID="R01200">
<Name>Гонконгский доллар</Name>
<EngName>Hong Kong Dollar</EngName>
<Nominal>10</Nominal>
<ParentCode>R01200 </ParentCode>
<ISO_Num_Code>344</ISO_Num_Code>
<ISO_Char_Code>HKD</ISO_Char_Code>
</Item>
<Item ID="R01215">
<Name>Датская крона</Name>
<EngName>Danish Krone</EngName>
<Nominal>10</Nominal>
<ParentCode>R01215 </ParentCode>
<ISO_Num_Code>208</ISO_Num_Code>
<ISO_Char_Code>DKK</ISO_Char_Code>
</Item>
<Item ID="R01235">
<Name>Доллар США</Name>
<EngName>US Dollar</EngName>
<Nominal>1</Nominal>
<ParentCode>R01235 </ParentCode>
<ISO_Num_Code>840</ISO_Num_Code>
<ISO_Char_Code>USD</ISO_Char_Code>
</Item>
<Item ID="R01239">
<Name>Евро</Name>
<EngName>Euro</EngName>
<Nominal>1</Nominal>
<ParentCode>R01239 </ParentCode>
<ISO_Num_Code>978</ISO_Num_Code>
<ISO_Char_Code>EUR</ISO_Char_Code>
</Item>
<Item ID="R01270">
<Name>Индийская рупия</Name>
<EngName>Indian Rupee</EngName>
<Nominal>100</Nominal>
<ParentCode>R01270 </ParentCode>
<ISO_Num_Code>356</ISO_Num_Code>
<ISO_Char_Code>INR</ISO_Char_Code>
</Item>
<Item ID="R01335">
<Name>Казахстанский тенге</Name>
<EngName>Kazakhstan Tenge</EngName>
<Nominal>100</Nominal>
<ParentCode>R01335 </ParentCode>
<ISO_Num_Code>398</ISO_Num_Code>
<ISO_Char_Code>KZT</ISO_Char_Code>
</Item>
<Item ID="R01350">
<Name>Канадский доллар</Name>
<EngName>Canadian Dollar</EngName>
<Nominal>1</Nominal>
<ParentCode>R01350 </ParentCode>
<ISO_Num_Code>124</ISO_Num_Code>
<ISO_Char_Code>CAD</ISO_Char_Code>
</Item>
<Item ID="R01370">
<Name>Киргизский сом</Name>
<EngName>Kyrgyzstan Som</EngName>
<Nominal>100</Nominal>
<ParentCode>R01370 </ParentCode>
<ISO_Num_Code>417</ISO_Num_Code>
<ISO_Char_Code>KGS</ISO_Char_Code>
</Item>
<Item ID="R01375">
<Name>Китайский юань</Name>
<EngName>China Yuan</EngName>
<Nominal>10</Nominal>
<ParentCode>R01375 </ParentCode>
<ISO_Num_Code>156</ISO_Num_Code>
<ISO_Char_Code>CNY</ISO_Char_Code>
</Item>
<Item ID="R01500">
<Name>Молдавский лей</Name>
<EngName>Moldova Lei</EngName>
<Nominal>10</Nominal>
<ParentCode>R01500 </ParentCode>
<ISO_Num_Code>498</ISO_Num_Code>
<ISO_Char_Code>MDL</ISO_Char_Code>
</Item>
<Item ID="R01535">
<Name>Норвежская крона</Name>
<EngName>Norwegian Krone</EngName>
<Nominal>10</Nominal>
<ParentCode>R01535 </ParentCode>
<ISO_Num_Code>578</ISO_Num_Code>
<ISO_Char_Code>NOK</ISO_Char_Code>
</Item>
<Item ID="R01565">
<Name>Польский злотый</Name>
<EngName>Polish Zloty</EngName>
<Nominal>1</Nominal>
<ParentCode>R01565 </ParentCode>
<ISO_Num_Code>985</ISO_Num_Code>
<ISO_Char_Code>PLN</ISO_Char_Code>
</Item>
<Item ID="R01585F">
<Name>Румынский лей</Name>
<EngName>Romanian Leu</EngName>
<Nominal>10</Nominal>
<ParentCode>R01585 </ParentCode>
<ISO_Num_Code>946</ISO_Num_Code>
<ISO_Char_Code>RON</ISO_Char_Code>
</Item>
<Item ID="R01589">
<Name>СДР (специальные права заимствования)</Name>
<EngName>SDR</EngName>
<Nominal>1</Nominal>
<ParentCode>R01589 </ParentCode>
<ISO_Num_Code>960</ISO_Num_Code>
<ISO_Char_Code>XDR</ISO_Char_Code>
</Item>
<Item ID="R01625">
<Name>Сингапурский доллар</Name>
<EngName>Singapore Dollar</EngName>
<Nominal>1</Nominal>
<ParentCode>R01625 </ParentCode>
<ISO_Num_Code>702</ISO_Num_Code>
<ISO_Char_Code>SGD</ISO_Char_Code>
</Item>
<Item ID="R01670">
<Name>Таджикский сомони</Name>
<EngName>Tajikistan Ruble</EngName>
<Nominal>10</Nominal>
<ParentCode>R01670 </ParentCode>
<ISO_Num_Code>972</ISO_Num_Code>
<ISO_Char_Code>TJS</ISO_Char_Code>
</Item>
<Item ID="R01700J">
<Name>Турецкая лира</Name>
<EngName>Turkish Lira</EngName>
<Nominal>1</Nominal>
<ParentCode>R01700 </ParentCode>
<ISO_Num_Code>949</ISO_Num_Code>
<ISO_Char_Code>TRY</ISO_Char_Code>
</Item>
<Item ID="R01710A">
<Name>Новый туркменский манат</Name>
<EngName>New Turkmenistan Manat</EngName>
<Nominal>1</Nominal>
<ParentCode>R01710 </ParentCode>
<ISO_Num_Code>934</ISO_Num_Code>
<ISO_Char_Code>TMT</ISO_Char_Code>
</Item>
<Item ID="R01717">
<Name>Узбекский сум</Name>
<EngName>Uzbekistan Sum</EngName>
<Nominal>1000</Nominal>
<ParentCode>R01717 </ParentCode>
<ISO_Num_Code>860</ISO_Num_Code>
<ISO_Char_Code>UZS</ISO_Char_Code>
</Item>
<Item ID="R01720">
<Name>Украинская гривна</Name>
<EngName>Ukrainian Hryvnia</EngName>
<Nominal>10</Nominal>
<ParentCode>R01720 </ParentCode>
<ISO_Num_Code>980</ISO_Num_Code>
<ISO_Char_Code>UAH</ISO_Char_Code>
</Item>
<Item ID="R01760">
<Name>Чешская крона</Name>
<EngName>Czech Koruna</EngName>
<Nominal>10</Nominal>
<ParentCode>R01760 </ParentCode>
<ISO_Num_Code>203</ISO_Num_Code>
<ISO_Char_Code>CZK</ISO_Char_Code>
</Item>
<Item ID="R01770">
<Name>Шведская крона</Name>
<EngName>Swedish Krona</EngName>
<Nominal>10</Nominal>
<ParentCode>R01770 </ParentCode>
<ISO_Num_Code>752</ISO_Num_Code>
<ISO_Char_Code>SEK</ISO_Char_Code>
</Item>
<Item ID="R01775">
<Name>Швейцарский франк</Name>
<EngName>Swiss Franc</EngName>
<Nominal>1</Nominal>
<ParentCode>R01775 </ParentCode>
<ISO_Num_Code>756</ISO_Num_Code>
<ISO_Char_Code>CHF</ISO_Char_Code>
</Item>
<Item ID="R01810">
<Name>Южноафриканский рэнд</Name>
<EngName>S.African Rand</EngName>
<Nominal>10</Nominal>
<ParentCode>R01810 </ParentCode>
<ISO_Num_Code>710</ISO_Num_Code>
<ISO_Char_Code>ZAR</ISO_Char_Code>
</Item>
<Item ID="R01815">
<Name>Вон Республики Корея</Name>
<EngName>South Korean Won</EngName>
<Nominal>1000</Nominal>
<ParentCode>R01815 </ParentCode>
<ISO_Num_Code>410</ISO_Num_Code>
<ISO_Char_Code>KRW</ISO_Char_Code>
</Item>
<Item ID="R01820">
<Name>Японская иена</Name>
<EngName>Japanese Yen</EngName>
<Nominal>100</Nominal>
<ParentCode>R01820 </ParentCode>
<ISO_Num_Code>392</ISO_Num_Code>
<ISO_Char_Code>JPY</ISO_Char_Code>
</Item>
</Valuta>
]]
