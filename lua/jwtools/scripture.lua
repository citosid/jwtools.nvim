local M = {}

local books = require("jwtools.books")
local config = require("jwtools.config")

--- Parse verse list which may contain single verses, comma-separated verses, or ranges
--- Examples: "1", "1,2,3", "1-3", "1,3-5,7"
---@param verse_list string The verse portion after "chapter:"
---@return table[] List of { start_verse: number, end_verse: number }
local function parse_verse_list(verse_list)
	local verses = {}

	-- First, extract just the verse numbers portion (stop at space or end)
	local verse_part = verse_list:match("^([%d%s,%-]+)")
	if not verse_part then
		return verses
	end

	-- Split by comma and process each part
	for part in verse_part:gmatch("([^,]+)") do
		part = part:match("^%s*(.-)%s*$") -- trim whitespace

		-- Check if it's a range (e.g., "1-3")
		local range_start, range_end = part:match("^(%d+)%-(%d+)$")
		if range_start and range_end then
			table.insert(verses, {
				start_verse = tonumber(range_start),
				end_verse = tonumber(range_end),
			})
		else
			-- Single verse
			local single = part:match("^(%d+)$")
			if single then
				table.insert(verses, {
					start_verse = tonumber(single),
					end_verse = tonumber(single),
				})
			end
		end
	end

	return verses
end

local function parse_verses(line)
	local scriptures = {}
	for book, chapter, verse_list in line:gmatch("([%d%aáéíóúÁÉÍÓÚñÑ.]+)%s*(%d+):([%d%s,%-]+)") do
		local language = config.get("language")
		local resolved_book = books.resolve_book_name(book, language)

		if resolved_book then
			local verses = parse_verse_list(verse_list)

			if #verses > 0 then
				table.insert(scriptures, {
					book = resolved_book,
					chapter = tonumber(chapter),
					verses = verses,
					start_pos = line:find(book .. "%s*" .. chapter .. ":"),
				})
			end
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

		-- If it's a range, include the end verse
		if verse.end_verse ~= verse.start_verse then
			local range_end = string.format("%s%03d%03d", book_num, nearest_scripture.chapter, verse.end_verse)
			return range_start .. "-" .. range_end
		end

		return range_start
	end

	error("No verses found in scripture reference")
	return nil
end

M.get_reference_id = get_reference_id

return M
