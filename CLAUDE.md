# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is the official AIO Launcher scripts repository. AIO Launcher is an Android launcher that supports custom Lua scripts for widgets, search functionality, and side menu customization. Scripts are written in Lua 5.2 (LuaJ 3.0.1 interpreter) and run on Android devices.

## Script Types and Architecture

### Three Script Categories

1. **Widget scripts** (`-- type = "widget"`): Display information on the home screen
   - Entry points: `on_load()`, `on_resume()`, `on_alarm()`, `on_tick()`
   - Use `on_alarm()` for network-based widgets (auto-updates every 30 min)
   - Use `on_resume()` for scripts that update when returning to home screen
   - Use `on_tick(n)` for real-time updates (called every second)

2. **Search scripts** (`-- type = "search"`): Add custom search results
   - Entry point: `on_search(query)` triggered on each character typed
   - Can use prefix matching via `-- prefix="youtube|yt"` metadata
   - Display results with `search:show_buttons()`, `search:show_lines()`, etc.
   - Return `true` from `on_click()` to close search window

3. **Drawer/Side menu scripts** (`-- type = "drawer"`): Customize app drawer
   - Entry point: `on_drawer_open()`
   - Display lists with `drawer:show_list()` or `drawer:show_ext_list()`
   - Support icons, badges, and alphabetical indexing

### Repository Structure

- `main/` - Core scripts bundled with AIO Launcher (official)
- `community/` - Community-contributed scripts
- `samples/` - Example scripts demonstrating APIs
- `lib/` - Shared Lua modules (json, xml, html, csv, fmt, date, etc.)
- `dev/` - Development/testing scripts
- `defunct/` - Deprecated/non-functional scripts (APIs changed or services unavailable)
- `ru/` - Russian language specific scripts

### Key Architectural Patterns

**Callback-driven execution**: Scripts don't have a main loop. They respond to lifecycle callbacks:
- Network requests use async callbacks: `on_network_result(body, code, headers)`
- Dialog actions: `on_dialog_action(value)`
- User interaction: `on_click(idx)`, `on_long_click(idx)`

**State management**: Use global variables or the `prefs` module for persistence:
```lua
prefs = require "prefs"
prefs.my_key = "value"  -- Auto-saved to disk
```

**UI rendering**: Each UI function clears and redraws the entire widget:
- Simple UI: `ui:show_text()`, `ui:show_lines()`, `ui:show_buttons()`, `ui:show_table()`
- Advanced UI: `gui()` function for precise layout control
- Use HTML/Markdown formatting with prefixes `%%mkd%%` or `%%txt%%`

## Development Workflow

### Testing Scripts

**On Android device via ADB**:
```bash
# Push scripts to device
./install-scripts.sh  # Pushes all scripts from configured repos
./install-one-script.sh <filename>  # Push single script

# Remove all scripts from device
./rm-scripts.sh
```

Scripts are auto-reloaded when:
- Returning to home screen (widget scripts)
- Opening search window (search scripts)
- Opening side menu (drawer scripts)

**Distribution**:
```bash
# Create update.zip for official distribution
./gen_zip.sh  # Packages main/ and ru/ scripts
```

### Script Development Guidelines

**Metadata requirements** (use double quotes, not single):
```lua
-- name = "Widget Name"
-- description = "Brief description"
-- type = "widget"
-- author = "Name (email)"
-- version = "1.0"
-- foldable = "true"  -- Optional: allow widget folding
-- lang = "ru"  -- Optional: language-specific
-- prefix = "cmd|alias"  -- For search scripts only
```

**Legacy API handling**: Some scripts use deprecated `ajson` module (replaced by `json` from json.lua). When modernizing, use:
```lua
local json = require "json"
local data = json.decode(result)
```

**Error handling for network requests**:
```lua
function on_network_result(result, code)
    if code >= 200 and code < 299 then
        local ok, parsed = pcall(json.decode, result)
        if not ok or type(parsed) ~= "table" then
            ui:show_text("Invalid data")
            return
        end
        -- Process data
    end
end
```

**Using shared libraries**:
- `fmt` module: HTML formatting helpers (`fmt.bold()`, `fmt.colored()`, etc.)
- `md_colors` module: Material Design color palette
- `url` module: URL encoding/decoding
- `date` module: Advanced date/time operations
- `xml`, `html`, `csv` modules: Parsing structured data

## Important Constraints

**LuaJ limitations**:
- No `io` or `package` modules (security)
- Limited `os` module: only `os.clock()`, `os.date()`, `os.difftime()`, `os.time()`
- No file system access except via `files:read()`, `files:write()`, `files:delete()`
- Files stored in `/sdcard/Android/data/ru.execbit.aiolauncher/files/scripts/`

**API-specific notes**:
- Network requests are async - never block waiting for results
- Multiple network requests need unique IDs: `http:get(url, "id")` → `on_network_result_id()`
- Shell commands: `system:exec(cmd, "id")` → `on_shell_result_id()`
- Icons use FontAwesome up to v6.3.0: `fa:icon_name` or `%%fa:icon_name%%`
- Use `%%fa-fw:icon_name%%` for fixed-width icon alignment

**UI patterns**:
- Each `ui:show_*()` call replaces entire widget content
- For animations/partial updates: use `morph` and `anim` modules
- Widget folding: first line shown when folded (or use `on_resume_when_folding = "true"`)

## Common Debugging

**Debug helpers**:
```lua
debug:log(text)    -- Log to system
debug:toast(text)  -- Show toast message
debug:dialog(text) -- Show dialog

-- Mark scripts as testing (grayed out in menu)
-- testing = "true"
```

**Checking API availability**:
```lua
if ui.show_list_dialog then
    -- API available
end
```

**Version requirements**: Use `-- aio_version = "4.1.3"` to hide script on older AIO versions.

## Script Migration Notes

When updating old scripts:
1. Replace `ajson` with `json` module
2. Check for deprecated `settings` module → use `prefs` instead
3. Verify network error handling includes proper status code checks
4. Update to new API signatures (e.g., `http:get()` now returns headers)
5. Test with current AIO Launcher version (check CHANGELOG.md for breaking changes)

## File Naming Conventions

- Widget files: `*-widget.lua`
- Search scripts: `*-search.lua`
- Menu scripts: `*-menu.lua`
- Samples: `*-sample.lua`
- Test scripts: `*-test.lua`

## Resources

- Full API documentation: README.md
- Beginner tutorial: README_INTRO.md
- Advanced Rich UI: README_RICH_UI.md
- App widget integration: README_APP_WIDGETS.md
- AI prompt for generating scripts: PROMPT.md
- Changelog: CHANGELOG.md
