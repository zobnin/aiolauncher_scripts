function on_resume()
  local s1 = {
    key1 = "123",
    key2 = "val ue   2",
  }

  settings:set_kv(s1)

  local s2 = settings:get_kv()

  ui:show_text("key1=\""..s2.key1.."\" ".."key2=\""..s2.key2.."\"")
end

