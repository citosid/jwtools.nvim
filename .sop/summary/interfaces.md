# Interfaces & APIs

## Plugin Interface

### User-Facing Commands

```lua
require("jwtools").setup(opts)
```
- **Type**: Initialization function
- **Parameters**: `opts` (table, optional)
  - `language` (string): "es" or "en", default: "es"
  - `keymaps` (boolean): Enable default keymaps, default: true
- **Returns**: nil
- **Effects**: Initializes plugin, registers keymaps, sets up configuration

```lua
require("jwtools").select_language()
```
- **Type**: Interactive function
- **Parameters**: none
- **Returns**: nil
- **Effects**: Opens language selection menu, updates config

## Module Interfaces

### config Module

```lua
Config.setup(opts)
```
- Merges user options into settings
- Validates keys, warns on invalid keys
- **Parameters**: `opts` (table, optional)

```lua
Config.get(key)
```
- Retrieve setting value
- **Parameters**: `key` (string)
- **Returns**: any - the setting value

```lua
Config.set(key, value)
```
- Update setting value
- **Parameters**: `key` (string), `value` (any)
- **Returns**: nil
- **Effects**: Updates setting, warns if key invalid

### fetch Module

```lua
M.fetch_scripture()
```
- Parse scripture reference from current line, fetch from jw.org, display tooltip, store in register
- **Parameters**: none
- **Returns**: nil
- **Effects**: 
  - Shows spinner during fetch
  - Displays tooltip with verse content
  - Stores formatted scripture in register "j"
  - Notifies on errors

```lua
M.yank_scripture()
```
- Parse scripture reference, fetch, store in register (no tooltip)
- **Parameters**: none
- **Returns**: nil
- **Effects**: Stores formatted scripture in register "j"

### scripture Module

```lua
M.get_reference()
```
- Extract scripture reference from current line at cursor
- **Parameters**: none
- **Returns**: {book, chapter, verses} or nil
- **Usage**: Called by fetch to identify what scripture user references

```lua
M.parse_reference(ref_string, language)
```
- Convert text reference to API ref_id
- **Parameters**: `ref_string` (string), `language` (string)
- **Returns**: string - API ref_id or nil on failure
- **Example**: "John 3:16" → "43_3_16-16" (en)

### paste Module

```lua
M.paste_scripture()
```
- Insert scripture from register j at cursor
- **Parameters**: none
- **Returns**: nil
- **Effects**:
  - Normal mode: Inserts blockquote below cursor
  - Visual mode: Replaces selection with blockquote
  - Warns if register empty

### tooltip Module

```lua
M.show_verse_tooltip(ref_id, json)
```
- Display verse content in floating window
- **Parameters**: 
  - `ref_id` (string): API reference ID
  - `json` (table): Parsed jw.org JSON response
- **Returns**: nil
- **Effects**: Shows floating window centered on cursor

### books Module

Returns table of book name mappings:

```lua
local books = require("jwtools.books")
local mappings = books[language]  -- language: "es" or "en"
mappings[book_name]  -- Returns canonical abbreviation
```

### language_urls Module

```lua
LanguageURLs.get_url(language, ref_id)
```
- Construct jw.org API URL
- **Parameters**: `language` (string), `ref_id` (string)
- **Returns**: string - Full API URL or nil
- **Example**: ("en", "43_3_16-16") → "https://www.jw.org/en/library/bible/study-bible/books/json/html/43_3_16-16"

## External API Interfaces

### jw.org JSON API

**Endpoint Pattern**:
- Spanish: `https://www.jw.org/es/biblioteca/biblia/biblia-estudio/libros/json/html/{ref_id}`
- English: `https://www.jw.org/en/library/bible/study-bible/books/json/html/{ref_id}`

**Request**:
- Method: GET
- Headers: Standard browser headers (User-Agent, Accept, etc.)
- Cookies: Session cookies from jw.org homepage

**Response Format**:
```json
{
  "ranges": {
    "{ref_id}": {
      "citation": "John 3:16",
      "verses": [
        { "content": "<p>16 For God loved...</p>" },
        { "content": "<p>17 For God did not...</p>" }
      ]
    }
  }
}
```

**Error Cases**:
- Invalid ref_id: Returns empty or malformed JSON
- Network timeout: curl exits with non-zero code
- Session expired: Cookies refreshed automatically

## Neovim API Usage

### Core APIs Used

```lua
vim.keymap.set(mode, lhs, rhs, opts)
```
- Register keymaps (init.lua)

```lua
vim.ui.select(items, opts, callback)
```
- Interactive menu for language selection

```lua
vim.notify(message, level)
```
- User notifications (errors, warnings, info)

```lua
vim.fn.jobstart(cmd, opts)
```
- Execute curl asynchronously
- Callbacks: `on_exit`, `on_stdout`

```lua
vim.fn.getreg(register)
vim.fn.setreg(register, content)
```
- Read/write clipboard register

```lua
vim.api.nvim_get_current_buf()
vim.api.nvim_get_current_win()
vim.api.nvim_win_get_cursor(window)
```
- Get cursor position and buffer context

```lua
vim.api.nvim_open_win(buffer, enter, config)
```
- Create floating window for tooltips

```lua
vim.schedule(callback)
```
- Schedule callback on main event loop

```lua
vim.bo.textwidth
```
- Access buffer-local options (for wrapping width)

## Data Format Specifications

### Register j Content Format

```
**Citation Text**

Verse content line 1
Verse content line 2
...
```

**Example**:
```
**John 3:16-17**

16 For God loved the world so much...
17 For God did not send his Son...
```

### Reference ID Format (API)

`{book_code}_{chapter}_{verse_start}-{verse_end}`

**Examples**:
- "43_3_16-16" (John 3:16)
- "43_3_16-18" (John 3:16-18)
- "43_3_1-5,10-12" (Multiple ranges)

Book codes are numeric (1=Genesis, 43=John, etc.)

## Integration Points

### For Language Support

1. Add mappings to `books.lua` for new language
2. Add URL pattern to `language_urls.lua`
3. Update `init.lua` available_languages list
4. Test verse parsing with new script variations

### For UI Customization

1. Modify `tooltip.lua` `show_verse_tooltip()` for display format
2. Modify `paste.lua` `format_as_blockquote()` for output format
3. Adjust wrapping width and styling

### For Source Customization

1. Modify `language_urls.lua` to point to different API
2. Adjust JSON parsing in `fetch.lua` if response structure differs
3. Update `tooltip.lua` HTML stripping if needed
