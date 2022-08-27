-- name = "Horoscope"
-- description = "Horoscope for a given day"
-- arguments_default = "scorpio today en"
-- type = "widget"
-- version = "1.0"
-- author = "Andrey Gavrilov"

local json = require "json"
local horo = ""
local dialog_id = ""
local days = {"today","tomorrow","yesterday"}
local signs = {"aries","taurus","gemini","cancer","leo","virgo","libra","scorpio","sagittarius","capricorn","aquarius","pisces"}

function on_alarm()
    local args = settings:get()
    ui:set_title(ui:get_default_title().." ("..args[1].." - "..args[2]..")")
    http:post("https://aztro.sameerkumar.website/?sign="..args[1].."&day="..args[2],"","","horo")
end

function on_network_result_horo(result)
    local t = json.decode(result)
    horo = t.description
    local args = settings:get()
    if args[3] == "en" then
        ui:show_text(horo)
    else
        http:get("http://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl="..args[3].."&dt=t&q="..horo,"tran")
    end
end

function on_network_result_tran(result)
    local t = json.decode(result)
    local text = ""
    for i, v in ipairs(t[1]) do
        text = text..v[1]
    end
    horo = text
    ui:show_text(horo)
end

function on_click()
    dialog_id = "day"
    local args = settings:get()
    ui:show_radio_dialog("Select date",days,get_index(days,args[2]))
end

function on_long_click()
    system:copy_to_clipboard(horo)
end

function on_settings()
    dialog_id = "setting"
    ui:show_radio_dialog("Select settings",{"sign","language"})
end

function on_dialog_action(data)
    if data == -1 then
        return
    end
    local args = settings:get()
    if dialog_id == "setting" then
        if data == 1 then
            dialog_id = "sign"
            ui:show_radio_dialog("Select sign",signs,get_index(signs,args[1]))
        elseif data == 2 then
            dialog_id = "lang"
            local t = json.decode(all_langs)
            local langs = table_to_tables(t)
            ui:show_radio_dialog("Select language",langs[2],get_index(langs[1],args[3]))
        end
    elseif dialog_id == "day" then
        if args[2] ~= days[data] then
            args[2] = days[data]
            settings:set(args)
            on_alarm()
        end
    elseif dialog_id == "sign" then
        if args[1] ~= signs[data] then
            args[1] = signs[data]
            settings:set(args)
            on_alarm()
        end
    elseif dialog_id == "lang" then
        local t = json.decode(all_langs)
        local langs = table_to_tables(t)
        if args[3] ~= langs[1][data] then
            args[3] = langs[1][data]
            settings:set(args)
            on_alarm()
        end
    end
end

function table_to_tables(t)
	local key = {}
	local value = {}
	for i,v in ipairs(t) do
		table.insert(key,v.code)
		table.insert(value,v.code.." ("..v.name..")")
	end
	return {key,value}
end

all_langs = [[
[
  { "code": "aa", "name": "Afar" },
  { "code": "ab", "name": "Abkhazian" },
  { "code": "ae", "name": "Avestan" },
  { "code": "af", "name": "Afrikaans" },
  { "code": "ak", "name": "Akan" },
  { "code": "am", "name": "Amharic" },
  { "code": "an", "name": "Aragonese" },
  { "code": "ar", "name": "Arabic" },
  { "code": "as", "name": "Assamese" },
  { "code": "av", "name": "Avaric" },
  { "code": "ay", "name": "Aymara" },
  { "code": "az", "name": "Azerbaijani" },
  { "code": "ba", "name": "Bashkir" },
  { "code": "be", "name": "Belarusian" },
  { "code": "bg", "name": "Bulgarian" },
  { "code": "bh", "name": "Bihari languages" },
  { "code": "bi", "name": "Bislama" },
  { "code": "bm", "name": "Bambara" },
  { "code": "bn", "name": "Bengali" },
  { "code": "bo", "name": "Tibetan" },
  { "code": "br", "name": "Breton" },
  { "code": "bs", "name": "Bosnian" },
  { "code": "ca", "name": "Catalan; Valencian" },
  { "code": "ce", "name": "Chechen" },
  { "code": "ch", "name": "Chamorro" },
  { "code": "co", "name": "Corsican" },
  { "code": "cr", "name": "Cree" },
  { "code": "cs", "name": "Czech" },
  {
    "code": "cu",
    "name": "Church Slavic; Old Slavonic; Church Slavonic; Old Bulgarian; Old Church Slavonic"
  },
  { "code": "cv", "name": "Chuvash" },
  { "code": "cy", "name": "Welsh" },
  { "code": "da", "name": "Danish" },
  { "code": "de", "name": "German" },
  { "code": "dv", "name": "Divehi; Dhivehi; Maldivian" },
  { "code": "dz", "name": "Dzongkha" },
  { "code": "ee", "name": "Ewe" },
  { "code": "el", "name": "Greek, Modern (1453-)" },
  { "code": "en", "name": "English" },
  { "code": "eo", "name": "Esperanto" },
  { "code": "es", "name": "Spanish; Castilian" },
  { "code": "et", "name": "Estonian" },
  { "code": "eu", "name": "Basque" },
  { "code": "fa", "name": "Persian" },
  { "code": "ff", "name": "Fulah" },
  { "code": "fi", "name": "Finnish" },
  { "code": "fj", "name": "Fijian" },
  { "code": "fo", "name": "Faroese" },
  { "code": "fr", "name": "French" },
  { "code": "fy", "name": "Western Frisian" },
  { "code": "ga", "name": "Irish" },
  { "code": "gd", "name": "Gaelic; Scomttish Gaelic" },
  { "code": "gl", "name": "Galician" },
  { "code": "gn", "name": "Guarani" },
  { "code": "gu", "name": "Gujarati" },
  { "code": "gv", "name": "Manx" },
  { "code": "ha", "name": "Hausa" },
  { "code": "he", "name": "Hebrew" },
  { "code": "hi", "name": "Hindi" },
  { "code": "ho", "name": "Hiri Motu" },
  { "code": "hr", "name": "Croatian" },
  { "code": "ht", "name": "Haitian; Haitian Creole" },
  { "code": "hu", "name": "Hungarian" },
  { "code": "hy", "name": "Armenian" },
  { "code": "hz", "name": "Herero" },
  {
    "code": "ia",
    "name": "Interlingua (International Auxiliary Language Association)"
  },
  { "code": "id", "name": "Indonesian" },
  { "code": "ie", "name": "Interlingue; Occidental" },
  { "code": "ig", "name": "Igbo" },
  { "code": "ii", "name": "Sichuan Yi; Nuosu" },
  { "code": "ik", "name": "Inupiaq" },
  { "code": "io", "name": "Ido" },
  { "code": "is", "name": "Icelandic" },
  { "code": "it", "name": "Italian" },
  { "code": "iu", "name": "Inuktitut" },
  { "code": "ja", "name": "Japanese" },
  { "code": "jv", "name": "Javanese" },
  { "code": "ka", "name": "Georgian" },
  { "code": "kg", "name": "Kongo" },
  { "code": "ki", "name": "Kikuyu; Gikuyu" },
  { "code": "kj", "name": "Kuanyama; Kwanyama" },
  { "code": "kk", "name": "Kazakh" },
  { "code": "kl", "name": "Kalaallisut; Greenlandic" },
  { "code": "km", "name": "Central Khmer" },
  { "code": "kn", "name": "Kannada" },
  { "code": "ko", "name": "Korean" },
  { "code": "kr", "name": "Kanuri" },
  { "code": "ks", "name": "Kashmiri" },
  { "code": "ku", "name": "Kurdish" },
  { "code": "kv", "name": "Komi" },
  { "code": "kw", "name": "Cornish" },
  { "code": "ky", "name": "Kirghiz; Kyrgyz" },
  { "code": "la", "name": "Latin" },
  { "code": "lb", "name": "Luxembourgish; Letzeburgesch" },
  { "code": "lg", "name": "Ganda" },
  { "code": "li", "name": "Limburgan; Limburger; Limburgish" },
  { "code": "ln", "name": "Lingala" },
  { "code": "lo", "name": "Lao" },
  { "code": "lt", "name": "Lithuanian" },
  { "code": "lu", "name": "Luba-Katanga" },
  { "code": "lv", "name": "Latvian" },
  { "code": "mg", "name": "Malagasy" },
  { "code": "mh", "name": "Marshallese" },
  { "code": "mi", "name": "Maori" },
  { "code": "mk", "name": "Macedonian" },
  { "code": "ml", "name": "Malayalam" },
  { "code": "mn", "name": "Mongolian" },
  { "code": "mr", "name": "Marathi" },
  { "code": "ms", "name": "Malay" },
  { "code": "mt", "name": "Maltese" },
  { "code": "my", "name": "Burmese" },
  { "code": "na", "name": "Nauru" },
  {
    "code": "nb",
    "name": "Bokmål, Norwegian; Norwegian Bokmål"
  },
  { "code": "nd", "name": "Ndebele, North; North Ndebele" },
  { "code": "ne", "name": "Nepali" },
  { "code": "ng", "name": "Ndonga" },
  { "code": "nl", "name": "Dutch; Flemish" },
  { "code": "nn", "name": "Norwegian Nynorsk; Nynorsk, Norwegian" },
  { "code": "no", "name": "Norwegian" },
  { "code": "nr", "name": "Ndebele, South; South Ndebele" },
  { "code": "nv", "name": "Navajo; Navaho" },
  { "code": "ny", "name": "Chichewa; Chewa; Nyanja" },
  { "code": "oc", "name": "Occitan (post 1500)" },
  { "code": "oj", "name": "Ojibwa" },
  { "code": "om", "name": "Oromo" },
  { "code": "or", "name": "Oriya" },
  { "code": "os", "name": "Ossetian; Ossetic" },
  { "code": "pa", "name": "Panjabi; Punjabi" },
  { "code": "pi", "name": "Pali" },
  { "code": "pl", "name": "Polish" },
  { "code": "ps", "name": "Pushto; Pashto" },
  { "code": "pt", "name": "Portuguese" },
  { "code": "qu", "name": "Quechua" },
  { "code": "rm", "name": "Romansh" },
  { "code": "rn", "name": "Rundi" },
  { "code": "ro", "name": "Romanian; Moldavian; Moldovan" },
  { "code": "ru", "name": "Russian" },
  { "code": "rw", "name": "Kinyarwanda" },
  { "code": "sa", "name": "Sanskrit" },
  { "code": "sc", "name": "Sardinian" },
  { "code": "sd", "name": "Sindhi" },
  { "code": "se", "name": "Northern Sami" },
  { "code": "sg", "name": "Sango" },
  { "code": "si", "name": "Sinhala; Sinhalese" },
  { "code": "sk", "name": "Slovak" },
  { "code": "sl", "name": "Slovenian" },
  { "code": "sm", "name": "Samoan" },
  { "code": "sn", "name": "Shona" },
  { "code": "so", "name": "Somali" },
  { "code": "sq", "name": "Albanian" },
  { "code": "sr", "name": "Serbian" },
  { "code": "ss", "name": "Swati" },
  { "code": "st", "name": "Sotho, Southern" },
  { "code": "su", "name": "Sundanese" },
  { "code": "sv", "name": "Swedish" },
  { "code": "sw", "name": "Swahili" },
  { "code": "ta", "name": "Tamil" },
  { "code": "te", "name": "Telugu" },
  { "code": "tg", "name": "Tajik" },
  { "code": "th", "name": "Thai" },
  { "code": "ti", "name": "Tigrinya" },
  { "code": "tk", "name": "Turkmen" },
  { "code": "tl", "name": "Tagalog" },
  { "code": "tn", "name": "Tswana" },
  { "code": "to", "name": "Tonga (Tonga Islands)" },
  { "code": "tr", "name": "Turkish" },
  { "code": "ts", "name": "Tsonga" },
  { "code": "tt", "name": "Tatar" },
  { "code": "tw", "name": "Twi" },
  { "code": "ty", "name": "Tahitian" },
  { "code": "ug", "name": "Uighur; Uyghur" },
  { "code": "uk", "name": "Ukrainian" },
  { "code": "ur", "name": "Urdu" },
  { "code": "uz", "name": "Uzbek" },
  { "code": "ve", "name": "Venda" },
  { "code": "vi", "name": "Vietnamese" },
  { "code": "vo", "name": "Volapük" },
  { "code": "wa", "name": "Walloon" },
  { "code": "wo", "name": "Wolof" },
  { "code": "xh", "name": "Xhosa" },
  { "code": "yi", "name": "Yiddish" },
  { "code": "yo", "name": "Yoruba" },
  { "code": "za", "name": "Zhuang; Chuang" },
  { "code": "zh", "name": "Chinese" },
  { "code": "zu", "name": "Zulu" }
]
]]
