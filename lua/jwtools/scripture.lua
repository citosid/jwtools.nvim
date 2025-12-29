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

--- Parse a single chapter:verses portion
--- Returns: { verses = [...], start_pos, end_pos } or nil
local function parse_chapter_verses(line, search_from, book_name, resolved_book, language)
	-- Find chapter:verses starting from search_from
	-- Pattern: digits (chapter), colon, then verse list
	local chapter_start = line:find("%d+:", search_from)
	if not chapter_start then
		return nil
	end

	local colon_pos = line:find(":", chapter_start)
	local chapter_str = line:sub(chapter_start, colon_pos - 1)
	local chapter = tonumber(chapter_str)
	if not chapter then
		return nil
	end

	-- Now find the verse list - continues until we hit a semicolon or end of line
	local verse_start = colon_pos + 1
	local verse_end = line:find(";", verse_start)
	if not verse_end then
		verse_end = #line
	else
		verse_end = verse_end - 1
	end

	local verse_list = line:sub(verse_start, verse_end)

	local verse_groups = {}
	local search_start = verse_start
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
		local full_match, verse_start_num, verse_end_num = verse_list:match("^((%d+)%-(%d+))", pos)
		if full_match then
			table.insert(verse_groups, {
				start_verse = tonumber(verse_start_num),
				end_verse = tonumber(verse_end_num),
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

	if #verse_groups == 0 then
		return nil
	end

	verse_groups = merge_consecutive_verses(verse_groups)

	return {
		book = resolved_book,
		chapter = chapter,
		verses = verse_groups,
		chapter_start = chapter_start,
		chapter_end = verse_end,
	}
end

--- Find all verse groups in a line with their byte positions
local function parse_scripture_references(line)
	local scriptures = {}
	local language = config.get("language")

	-- We'll track the current book being processed to handle semicolon continuations
	local current_book = nil
	local current_resolved_book = nil
	local pos = 1

	while pos <= #line do
		-- First, try to match a full book name (with optional leading digit)
		local book_match_start, book_match_end, book_text = line:find(
			"(%d?%s*[%aáéíóúÁÉÍÓÚñÑ]+%.?)",
			pos
		)

		local found_book = false

		if book_match_start then
			-- Clean up the captured book text
			local book = book_text:gsub("^%s+", ""):gsub("%s+$", "")
			if book ~= "" then
				-- Normalize book name: remove internal spaces before lookup
				local normalized_book = book:gsub("%s+", "")

				local resolved_book = books.resolve_book_name(normalized_book, language)

				if resolved_book then
					found_book = true
					current_book = book
					current_resolved_book = resolved_book
					pos = book_match_end + 1
				end
			end
		end

		-- Now try to parse chapter:verses
		-- This can come after a book name or after a semicolon (continuing the same book)
		if current_resolved_book then
			local chapter_result = parse_chapter_verses(line, pos, current_book, current_resolved_book, language)

			if chapter_result then
				table.insert(scriptures, {
					book = chapter_result.book,
					chapter = chapter_result.chapter,
					verses = chapter_result.verses,
					start_pos = found_book and book_match_start or pos,
					chapter_start = chapter_result.chapter_start,
					chapter_end = chapter_result.chapter_end,
				})

				-- Continue search after this reference
				pos = chapter_result.chapter_end + 1

				-- Skip semicolon if present (and stay in same book)
				if line:sub(pos, pos) == ";" then
					pos = pos + 1
				else
					-- No semicolon, reset book context
					current_book = nil
					current_resolved_book = nil
				end
			else
				-- No chapter:verses found, reset book context
				current_book = nil
				current_resolved_book = nil
				if found_book then
					pos = book_match_end + 1
				else
					pos = pos + 1
				end
			end
		else
			-- No current book and couldn't find a new one, advance
			if found_book then
				pos = book_match_end + 1
			else
				pos = pos + 1
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

	-- Find which scripture reference the cursor is in
	-- First, check if cursor is directly on any verse in any scripture
	local scripture_on_cursor = nil
	for _, scripture in ipairs(scriptures) do
		for _, verse in ipairs(scripture.verses) do
			if cursor_pos >= verse.start_pos and cursor_pos <= verse.end_pos then
				scripture_on_cursor = scripture
				break
			end
		end
		if scripture_on_cursor then
			break
		end
	end

	-- If not on a specific verse, find the nearest scripture reference
	if not scripture_on_cursor then
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

		scripture_on_cursor = nearest_scripture
	end

	if not scripture_on_cursor then
		error("No valid scripture reference found")
		return nil
	end

	local language = config.get("language")
	local book_num = books.get_book_number(scripture_on_cursor.book, language)

	if not book_num then
		error("Invalid book")
		return nil
	end

	if not scripture_on_cursor.verses or #scripture_on_cursor.verses == 0 then
		error("No verses found in scripture reference")
		return nil
	end

	-- Find the verse group where cursor is directly on top of it, or use first verse group
	local selected_verse = scripture_on_cursor.verses[1]

	for _, verse in ipairs(scripture_on_cursor.verses) do
		if cursor_pos >= verse.start_pos and cursor_pos <= verse.end_pos then
			selected_verse = verse
			break
		end
	end

	-- Build the reference ID
	local range_start = string.format("%s%03d%03d", book_num, scripture_on_cursor.chapter, selected_verse.start_verse)

	if selected_verse.end_verse ~= selected_verse.start_verse then
		local range_end = string.format("%s%03d%03d", book_num, scripture_on_cursor.chapter, selected_verse.end_verse)
		return range_start .. "-" .. range_end
	end

	return range_start
end

M.get_reference_id = get_reference_id

return M
