local LanguageURLs = {}

LanguageURLs.url_patterns = {
	es = "https://www.jw.org/%s/biblioteca/biblia/biblia-estudio/libros/json/data/%s",
	en = "https://www.jw.org/%s/library/bible/study-bible/books/json/data/%s",
}

function LanguageURLs.get_url(language, ref_id)
	local pattern = LanguageURLs.url_patterns[language]
	if not pattern then
		vim.notify("Unsupported language: " .. language, vim.log.levels.ERROR)
		return nil
	end
	return string.format(pattern, language, ref_id)
end

return LanguageURLs
