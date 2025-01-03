local M = {}
local books = require("jwtools.books")

local function get_range(scripture, book_num)
	local range_start = string.format("%s%03d%03d", book_num, scripture.chapter, scripture.start_verse)
	local range_end = ""

	if scripture.next_chapter and scripture.end_verse then
		range_end = string.format("-%s%03d%03d", book_num, scripture.next_chapter, scripture.end_verse)
	elseif scripture.next_chapter and not scripture.end_verse then
		range_end = string.format("-%s%03d%03d", book_num, scripture.chapter, scripture.next_chapter)
	end

	return range_start .. range_end
end

local function get_reference_id(line, cursor_pos)
	local scriptures = {}
	for book, chapter, start_verse, next_chapter, end_verse in line:gmatch("(%w+)%s*(%d+):(%d+)%s*%-?%s*(%d*):?(%d*)") do
		table.insert(scriptures, {
			book = book,
			chapter = tonumber(chapter),
			start_verse = tonumber(start_verse),
			next_chapter = tonumber(next_chapter),
			end_verse = tonumber(end_verse),
			start_pos = line:find(book .. "%s*" .. chapter .. ":" .. start_verse),
		})
	end

	local nearest_scripture = nil
	local min_distance = math.huge
	for _, scripture in ipairs(scriptures) do
		local distance = math.abs(cursor_pos - scripture.start_pos)
		if distance < min_distance then
			nearest_scripture = scripture
			min_distance = distance
		end
	end

	if not nearest_scripture then
		return vim.notify("No valid scripture reference found")
	end

	local book_num = books[nearest_scripture.book]
	if not book_num then
		return vim.notify("Invalid book")
	end

	return get_range(nearest_scripture, book_num)
end

M.get_reference_id = get_reference_id

return M
