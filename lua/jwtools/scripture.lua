local M = {}

local books = require("jwtools.books")
local config = require("jwtools.config")

-- Non-breaking space bytes for pattern matching
local NBSP = string.char(0xC2, 0xA0)

--- Merge consecutive single verses into ranges
--- e.g., [{4,4}, {5,5}] -> [{4,5}]
--- but [{4,7}, {10,10}] stays as is
local function merge_consecutive_verses(verses)
	if #verses <= 1 then
		return verses
	end

	local merged = {}
	local current = {
		start_verse = verses[1].start_verse,
		end_verse = verses[1].end_verse,
		start_pos = verses[1].start_pos,
		end_pos = verses[1].end_pos,
	}

	for i = 2, #verses do
		local v = verses[i]
		if v.start_verse == current.end_verse + 1 then
			current.end_verse = v.end_verse
			current.end_pos = v.end_pos
		else
			table.insert(merged, current)
			current = {
				start_verse = v.start_verse,
				end_verse = v.end_verse,
				start_pos = v.start_pos,
				end_pos = v.end_pos,
			}
		end
	end

	table.insert(merged, current)
	return merged
end

--- Find all verse groups in a line with their byte positions
local function parse_scripture_references(line)
	local scriptures = {}
	local language = config.get("language")

	-- Pattern to match book, chapter, and verse list (including non-breaking spaces)
	for book, chapter, verse_list in line:gmatch("([%d%aáéíóúÁÉÍÓÚñÑ.]+)%s*(%d+):([%d%s,%-" .. NBSP .. "]+)") do
		local resolved_book = books.resolve_book_name(book, language)

		if resolved_book then
			-- Find where this match starts in the original line
			local pattern = book:gsub("([%.%-%+%*%?%^%$%(%)%[%]%%])", "%%%1")
			local match_start = line:find(pattern .. "%s*" .. chapter .. ":")

			if match_start then
				local colon_pos = line:find(":", match_start)
				local verse_groups = {}
				local search_start = colon_pos + 1

				local pos = 1
				while pos <= #verse_list do
					-- Skip whitespace, commas, and non-breaking spaces
					local skip = verse_list:match("^[%s," .. NBSP .. "]+", pos)
					if skip then
						pos = pos + #skip
						search_start = search_start + #skip
					end

					if pos > #verse_list then
						break
					end

					-- Try to match a range (e.g., "4-7")
					local full_match, verse_start, verse_end = verse_list:match("^((%d+)%-(%d+))", pos)
					if full_match then
						table.insert(verse_groups, {
							start_verse = tonumber(verse_start),
							end_verse = tonumber(verse_end),
							start_pos = search_start,
							end_pos = search_start + #full_match - 1,
						})
						pos = pos + #full_match
						search_start = search_start + #full_match
					else
						-- Try to match a single verse
						local single = verse_list:match("^(%d+)", pos)
						if single then
							table.insert(verse_groups, {
								start_verse = tonumber(single),
								end_verse = tonumber(single),
								start_pos = search_start,
								end_pos = search_start + #single - 1,
							})
							pos = pos + #single
							search_start = search_start + #single
						else
							break
						end
					end
				end

				if #verse_groups > 0 then
					verse_groups = merge_consecutive_verses(verse_groups)

					table.insert(scriptures, {
						book = resolved_book,
						chapter = tonumber(chapter),
						verses = verse_groups,
						start_pos = match_start,
					})
				end
			end
		end
	end

	return scriptures
end

local function get_reference_id(line, cursor_pos)
	local scriptures = parse_scripture_references(line)

	if #scriptures == 0 then
		error("No valid scripture reference found")
		return nil
	end

	-- Find the nearest scripture reference
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

	if not nearest_scripture.verses or #nearest_scripture.verses == 0 then
		error("No verses found in scripture reference")
		return nil
	end

	-- Find the verse group where cursor is directly on top of it
	local selected_verse = nearest_scripture.verses[1]

	for _, verse in ipairs(nearest_scripture.verses) do
		if cursor_pos >= verse.start_pos and cursor_pos <= verse.end_pos then
			selected_verse = verse
			break
		end
	end

	-- Build the reference ID
	local range_start = string.format("%s%03d%03d", book_num, nearest_scripture.chapter, selected_verse.start_verse)

	if selected_verse.end_verse ~= selected_verse.start_verse then
		local range_end = string.format("%s%03d%03d", book_num, nearest_scripture.chapter, selected_verse.end_verse)
		return range_start .. "-" .. range_end
	end

	return range_start
end

M.get_reference_id = get_reference_id

return M
