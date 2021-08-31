function on_resume()
  local s1 = {
    key1 = "value1",
    key2 = "value2",
  }

  settings:set_kv(s1)

  local s2 = settings:get_kv()

  ui:show_text("key1="..s2.key1.." ".."key2="..s2.key2)
end

function on_settings()
  local s = settings:get_kv()

  ui:show_dialog("Settings", "key1="..s.key1.." ".."key2="..s.key2)
end
