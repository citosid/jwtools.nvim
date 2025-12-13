local M = {}

local books = require("jwtools.books")
local config = require("jwtools.config")

local function parse_verses(line)
    local scriptures = {}
    for book, chapter, verse_list in line:gmatch("([%d%aáéíóúÁÉÍÓÚñÑ.]+)%s*(%d+):(.+)") do
        local language = config.get("language")
        local resolved_book = books.resolve_book_name(book, language)
        
        if resolved_book then
            local verses = {}
            for verse in verse_list:gmatch("%s*(%d+)%s*,?") do
                table.insert(verses, {
                    start_verse = tonumber(verse),
                    end_verse = tonumber(verse)
                })
            end
            
            table.insert(scriptures, {
                book = resolved_book,
                chapter = tonumber(chapter),
                verses = verses,
                start_pos = line:find(book .. "%s*" .. chapter .. ":")
            })
        end
    end
    
    return scriptures
end

local function get_reference_id(line, cursor_pos)
    local scriptures = parse_verses(line)
    
    if #scriptures == 0 then
        error("No valid scripture reference found")
        return nil
    end
    
    local nearest_scripture = nil
    local min_distance = math.huge
    
    for _, scripture in ipairs(scriptures) do
        if scripture.start_pos then
            local distance = math.abs(cursor_pos - scripture.start_pos)
            if distance < min_distance then
                nearest_scripture = scripture
                min_distance = distance
            end
        end
    end
    
    if not nearest_scripture then
        error("No valid scripture reference found")
        return nil
    end
    
    local language = config.get("language")
    local book_num = books.get_book_number(nearest_scripture.book, language)
    
    if not book_num then
        error("Invalid book")
        return nil
    end
    
    if nearest_scripture.verses and #nearest_scripture.verses > 0 then
        local verse = nearest_scripture.verses[1]
        local range_start = string.format("%s%03d%03d", book_num, nearest_scripture.chapter, verse.start_verse)
        return range_start
    end
    
    error("No verses found in scripture reference")
    return nil
end

M.get_reference_id = get_reference_id

return M