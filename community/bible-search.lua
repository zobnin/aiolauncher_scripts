-- name = "Bible Search"
-- type = "search"
-- author = "Evon Smith"
-- description = "Type in Bible book and chapter to open the YouVersion Bible App to that location right from the search window"
-- version = "2.0"

------------------------------------------------------------
-- Complete Bible books list with aliases and chapters
------------------------------------------------------------
local BOOKS = {
  { name = "Genesis", aliases = {"genesis","gen","ge"}, chapters = 50, osis = "GEN" },
  { name = "Exodus", aliases = {"exodus","exo","ex"}, chapters = 40, osis = "EXO" },
  { name = "Leviticus", aliases = {"leviticus","lev","le"}, chapters = 27, osis = "LEV" },
  { name = "Numbers", aliases = {"numbers","num","nu","nm"}, chapters = 36, osis = "NUM" },
  { name = "Deuteronomy", aliases = {"deuteronomy","deut","dt"}, chapters = 34, osis = "DEU" },
  { name = "Joshua", aliases = {"joshua","josh","jos"}, chapters = 24, osis = "JOS" },
  { name = "Judges", aliases = {"judges","judg","jdg"}, chapters = 21, osis = "JDG" },
  { name = "Ruth", aliases = {"ruth","ru"}, chapters = 4, osis = "RUT" },
  { name = "1 Samuel", aliases = {"1samuel","1sam","1sa","i samuel","1 sam"}, chapters = 31, osis = "1SA" },
  { name = "2 Samuel", aliases = {"2samuel","2sam","2sa","ii samuel","2 sam"}, chapters = 24, osis = "2SA" },
  { name = "1 Kings", aliases = {"1kings","1ki","i kings","1 ki"}, chapters = 22, osis = "1KI" },
  { name = "2 Kings", aliases = {"2kings","2ki","ii kings","2 ki"}, chapters = 25, osis = "2KI" },
  { name = "1 Chronicles", aliases = {"1chronicles","1chr","i chronicles","1 chr"}, chapters = 29, osis = "1CH" },
  { name = "2 Chronicles", aliases = {"2chronicles","2chr","ii chronicles","2 chr"}, chapters = 36, osis = "2CH" },
  { name = "Ezra", aliases = {"ezra","ezr"}, chapters = 10, osis = "EZR" },
  { name = "Nehemiah", aliases = {"nehemiah","neh","ne"}, chapters = 13, osis = "NEH" },
  { name = "Esther", aliases = {"esther","est","es"}, chapters = 10, osis = "EST" },
  { name = "Job", aliases = {"job","jb"}, chapters = 42, osis = "JOB" },
  { name = "Psalms", aliases = {"psalms","psalm","ps","psa"}, chapters = 150, osis = "PSA" },
  { name = "Proverbs", aliases = {"proverbs","prov","prv","pr"}, chapters = 31, osis = "PRO" },
  { name = "Ecclesiastes", aliases = {"ecclesiastes","eccl","ecc"}, chapters = 12, osis = "ECC" },
  { name = "Song of Solomon", aliases = {"songofsolomon","song","so","ss","song of songs","songs"}, chapters = 8, osis = "SNG" },
  { name = "Isaiah", aliases = {"isaiah","isa","is"}, chapters = 66, osis = "ISA" },
  { name = "Jeremiah", aliases = {"jeremiah","jer","je"}, chapters = 52, osis = "JER" },
  { name = "Lamentations", aliases = {"lamentations","lam","la"}, chapters = 5, osis = "LAM" },
  { name = "Ezekiel", aliases = {"ezekiel","ezek","eze"}, chapters = 48, osis = "EZK" },
  { name = "Daniel", aliases = {"daniel","dan","da"}, chapters = 12, osis = "DAN" },
  { name = "Hosea", aliases = {"hosea","hos","ho"}, chapters = 14, osis = "HOS" },
  { name = "Joel", aliases = {"joel","jl"}, chapters = 3, osis = "JOL" },
  { name = "Amos", aliases = {"amos","am"}, chapters = 9, osis = "AMO" },
  { name = "Obadiah", aliases = {"obadiah","obad","ob"}, chapters = 1, osis = "OBA" },
  { name = "Jonah", aliases = {"jonah","jon","jh"}, chapters = 4, osis = "JON" },
  { name = "Micah", aliases = {"micah","mic","mc"}, chapters = 7, osis = "MIC" },
  { name = "Nahum", aliases = {"nahum","nah","na"}, chapters = 3, osis = "NAM" },
  { name = "Habakkuk", aliases = {"habakkuk","hab","hb"}, chapters = 3, osis = "HAB" },
  { name = "Zephaniah", aliases = {"zephaniah","zeph","zep"}, chapters = 3, osis = "ZEP" },
  { name = "Haggai", aliases = {"haggai","hag","hg"}, chapters = 2, osis = "HAG" },
  { name = "Zechariah", aliases = {"zechariah","zech","zec"}, chapters = 14, osis = "ZEC" },
  { name = "Malachi", aliases = {"malachi","mal","ml"}, chapters = 4, osis = "MAL" },
  { name = "Matthew", aliases = {"matthew","matt","mt"}, chapters = 28, osis = "MAT" },
  { name = "Mark", aliases = {"mark","mk","mrk"}, chapters = 16, osis = "MRK" },
  { name = "Luke", aliases = {"luke","lk","luk"}, chapters = 24, osis = "LUK" },
  { name = "John", aliases = {"john","jn","jhn"}, chapters = 21, osis = "JHN" },
  { name = "Acts", aliases = {"acts","ac","acts of the apostles"}, chapters = 28, osis = "ACT" },
  { name = "Romans", aliases = {"romans","rom","ro"}, chapters = 16, osis = "ROM" },
  { name = "1 Corinthians", aliases = {"1corinthians","1cor","1co","i corinthians","1 cor"}, chapters = 16, osis = "1CO" },
  { name = "2 Corinthians", aliases = {"2corinthians","2cor","2co","ii corinthians","2 cor"}, chapters = 13, osis = "2CO" },
  { name = "Galatians", aliases = {"galatians","gal","ga"}, chapters = 6, osis = "GAL" },
  { name = "Ephesians", aliases = {"ephesians","eph","ep"}, chapters = 6, osis = "EPH" },
  { name = "Philippians", aliases = {"philippians","phil","php"}, chapters = 4, osis = "PHP" },
  { name = "Colossians", aliases = {"colossians","col","co"}, chapters = 4, osis = "COL" },
  { name = "1 Thessalonians", aliases = {"1thessalonians","1thess","1th","i thessalonians","1 thess"}, chapters = 5, osis = "1TH" },
  { name = "2 Thessalonians", aliases = {"2thessalonians","2thess","2th","ii thessalonians","2 thess"}, chapters = 3, osis = "2TH" },
  { name = "1 Timothy", aliases = {"1timothy","1tim","1ti","i timothy","1 tim"}, chapters = 6, osis = "1TI" },
  { name = "2 Timothy", aliases = {"2timothy","2tim","2ti","ii timothy","2 tim"}, chapters = 4, osis = "2TI" },
  { name = "Titus", aliases = {"titus","tit","ti"}, chapters = 3, osis = "TIT" },
  { name = "Philemon", aliases = {"philemon","philem","phm"}, chapters = 1, osis = "PHM" },
  { name = "Hebrews", aliases = {"hebrews","heb","he"}, chapters = 13, osis = "HEB" },
  { name = "James", aliases = {"james","jas","jm"}, chapters = 5, osis = "JAS" },
  { name = "1 Peter", aliases = {"1peter","1pet","1pe","i peter","1 pet"}, chapters = 5, osis = "1PE" },
  { name = "2 Peter", aliases = {"2peter","2pet","2pe","ii peter","2 pet"}, chapters = 3, osis = "2PE" },
  { name = "1 John", aliases = {"1john","1jn","i john","1 jn"}, chapters = 5, osis = "1JN" },
  { name = "2 John", aliases = {"2john","2jn","ii john","2 jn"}, chapters = 1, osis = "2JN" },
  { name = "3 John", aliases = {"3john","3jn","iii john","3 jn"}, chapters = 1, osis = "3JN" },
  { name = "Jude", aliases = {"jude","jud"}, chapters = 1, osis = "JUD" },
  { name = "Revelation", aliases = {"revelation","rev","re","revelations"}, chapters = 22, osis = "REV" },
}

-- Build alias lookup table
local ALIAS = {}
local function _norm(s) return (s or ""):lower():gsub("[%s%p]+","") end
for _, b in ipairs(BOOKS) do
  ALIAS[_norm(b.name)] = b
  for _, a in ipairs(b.aliases) do ALIAS[_norm(a)] = b end
end

------------------------------------------------------------
-- State management
------------------------------------------------------------
local suggestions = {}  -- Store all clickable suggestions with their URLs
local currentQuery = ""

------------------------------------------------------------
-- Helper functions
------------------------------------------------------------
local function trim(s) return (s or ""):match("^%s*(.-)%s*$") end

-- Enhanced parser that handles multi-word book names better
local function parse_book_chapter(q)
  q = trim(q or "")
  if q == "" then return nil, nil end

  -- Try to match book name with optional chapter
  -- This pattern allows for multi-word book names
  local book_part, chapter_part = q:match("^(.-)%s+(%d+)$")

  if book_part and chapter_part then
    -- Found both book and chapter
    return trim(book_part), tonumber(chapter_part)
  else
    -- No chapter number found, treat entire query as book name
    return q, nil
  end
end

-- Enhanced book resolver for better multi-word matching
local function resolve_book(letters)
  if not letters then return nil end

  local key = _norm(letters)

  -- Exact match first
  if ALIAS[key] then return ALIAS[key] end

  -- Try partial matching for better multi-word support
  local matches = {}
  for ak, b in pairs(ALIAS) do
    if ak:find("^" .. key) then
      table.insert(matches, {alias = ak, book = b, priority = 1})
    elseif ak:find(key, 1, true) then
      table.insert(matches, {alias = ak, book = b, priority = 2})
    end
  end

  -- Return best match if found
  if #matches > 0 then
    table.sort(matches, function(a, b)
      if a.priority == b.priority then
        return #a.alias < #b.alias  -- Prefer shorter matches
      end
      return a.priority < b.priority
    end)
    return matches[1].book
  end

  return nil
end

local function build_youversion_url(osis, chapter)
  return string.format("youversion://bible?reference=%s.%d", osis, chapter)
end

-- Get matching books based on query
local function get_matching_books(query)
  if not query or query == "" then
    return BOOKS  -- Return all books if no query
  end

  local matches = {}
  local key = _norm(query)

  for _, book in ipairs(BOOKS) do
    local book_key = _norm(book.name)
    local is_match = false

    -- Check if book name starts with query
    if book_key:find("^" .. key) then
      is_match = true
    else
      -- Check aliases
      for _, alias in ipairs(book.aliases) do
        if _norm(alias):find("^" .. key) then
          is_match = true
          break
        end
      end
    end

    if is_match then
      table.insert(matches, book)
    end
  end

  -- If no matches found with prefix matching, try substring matching
  if #matches == 0 then
    for _, book in ipairs(BOOKS) do
      local book_key = _norm(book.name)
      if book_key:find(key, 1, true) then
        table.insert(matches, book)
      end
    end
  end

  return #matches > 0 and matches or BOOKS
end

------------------------------------------------------------
-- Main search function
------------------------------------------------------------
function on_search(query)
  currentQuery = query
  suggestions = {}

  local book_part, chapter = parse_book_chapter(query)

  if book_part then
    local specific_book = resolve_book(book_part)

    if specific_book and chapter then
      -- Specific book and chapter requested
      if chapter >= 1 and chapter <= specific_book.chapters then
        local url = build_youversion_url(specific_book.osis, chapter)
        suggestions[1] = {
          text = string.format("Open %s %d in YouVersion", specific_book.name, chapter),
          url = url
        }
        search:show_buttons({suggestions[1].text})
        return
      else
        search:show_lines({
          string.format("%s only has %d chapter%s",
            specific_book.name,
            specific_book.chapters,
            specific_book.chapters == 1 and "" or "s")
        })
        return
      end
    end
  end

  -- Show book/chapter suggestions
  local matching_books = get_matching_books(book_part)
  local button_texts = {}
  local max_suggestions = 10  -- Limit number of suggestions shown
  local suggestion_count = 0

  for _, book in ipairs(matching_books) do
    if suggestion_count >= max_suggestions then break end

    -- If book has few chapters, show all in one line
    if book.chapters <= 5 then
      local chapters_text = ""
      for ch = 1, book.chapters do
        if ch > 1 then chapters_text = chapters_text .. ", " end
        chapters_text = chapters_text .. ch
      end
      suggestion_count = suggestion_count + 1
      local idx = #suggestions + 1
      suggestions[idx] = {
        text = string.format("%s (Ch: %s)", book.name, chapters_text),
        book = book,
        all_chapters = true
      }
      table.insert(button_texts, suggestions[idx].text)
    else
      -- For books with many chapters, show range
      suggestion_count = suggestion_count + 1
      local idx = #suggestions + 1
      suggestions[idx] = {
        text = string.format("%s (1-%d chapters)", book.name, book.chapters),
        book = book,
        all_chapters = true
      }
      table.insert(button_texts, suggestions[idx].text)
    end
  end

  if #button_texts == 0 then
    search:show_lines({"No matching books found. Try: Genesis, John, Psalms..."})
  else
    search:show_buttons(button_texts)
  end
end

------------------------------------------------------------
-- Handle button clicks
------------------------------------------------------------
function on_click(index)
  if not index then index = 1 end

  local suggestion = suggestions[index]
  if not suggestion then return false end

  -- If it's a direct chapter link, open it
  if suggestion.url then
    system:open_browser(suggestion.url)
    return true
  end

  -- If it's a book suggestion, show its chapters
  if suggestion.book and suggestion.all_chapters then
    local book = suggestion.book
    suggestions = {}
    local button_texts = {}

    -- Create buttons for each chapter
    for ch = 1, book.chapters do
      local idx = #suggestions + 1
      local url = build_youversion_url(book.osis, ch)
      suggestions[idx] = {
        text = string.format("%s %d", book.name, ch),
        url = url
      }
      table.insert(button_texts, suggestions[idx].text)
    end

    search:show_buttons(button_texts)
    return false  -- Don't close search, allow chapter selection
  end

  return false
end

