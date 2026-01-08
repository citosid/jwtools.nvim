# AGENTS.md - AI Assistant Guide for jwtools.nvim

**Quick Start**: This file is your primary resource. Use [.sop/summary/index.md](.sop/summary/index.md) as a secondary knowledge base for detailed information on specific topics.

## Project Overview

**jwtools.nvim** is a Neovim plugin providing Bible study tools with JW.org integration. Users can fetch, parse, and insert scriptures in documents. Supports Spanish (es) and English (en).

**Key Stats**: 8 Lua modules, ~1,400 LOC, 2 languages, 66 books per language

## Directory Structure

```
lua/jwtools/
├── init.lua           # Setup, keymaps, lazy-loading
├── config.lua         # Settings (language, keymaps)
├── fetch.lua          # HTTP requests, parsing, async handling
├── scripture.lua      # Bible reference parsing & validation
├── paste.lua          # Scripture formatting & insertion
├── tooltip.lua        # Floating window display
├── books.lua          # Book name mappings (es/en)
└── language_urls.lua  # API endpoint URLs

plugin/
└── jwtools.lua        # Plugin loader hook

tests/
├── scripture_test.lua
├── books_test.lua
├── paste_test.lua
└── debug_cursor.lua
```

## Architecture Overview

```
User Input (Keymaps)
    ↓
init.lua (routing)
    ├→ Fetch Path: fetch.lua → scripture.lua → books.lua → tooltip.lua → curl
    ├→ Paste Path: paste.lua → format as blockquote
    └→ Config Path: config.lua → language selection

Data Flow:
scripture reference (text) → parsed (code) → API URL → HTTP response → register j → formatted output
```

**Design Principles**:
- **Modular**: Each feature isolated in separate module
- **Async**: HTTP requests non-blocking via `vim.fn.jobstart()`
- **Lazy-loaded**: Modules loaded on first use via metatable pattern
- **Config-driven**: Central config management, runtime language switching
- **Register-based**: Verse data stored in register "j" for clipboard operations

## Core Features & Workflows

### 1. Fetch Scripture (`<leader>jf`)
**File**: fetch.lua, scripture.lua, books.lua, tooltip.lua

**Flow**:
1. Parse reference from cursor line (e.g., "John 3:16")
2. Validate against book mappings
3. Check/refresh jw.org cookies
4. Build API URL with current language
5. Execute curl asynchronously
6. Display tooltip with verse content
7. Store formatted scripture in register j

**Data Format in Register**: `**Citation**\n\nVerse content`

**Error Handling**: Invalid ref → notify and abort; network error → retry with cookie refresh

### 2. Yank Scripture (`<leader>jy`)
**File**: fetch.lua

**Flow**: Same as fetch, but skip tooltip display (store to register only)

### 3. Paste Scripture (`<leader>jp`)
**File**: paste.lua

**Flow**:
1. Read stored scripture from register j
2. Parse citation and verse content
3. Format as markdown blockquote with `> ` prefix
4. Wrap text to `textwidth` (default 80)
5. Insert in normal mode or replace selection in visual mode

**Example Output**:
```
> **John 3:16**
>
> 16 For God loved the world so much...
```

### 4. Language Selection (`<leader>jl`)
**File**: init.lua, config.lua

**Flow**: Interactive menu → select language (es/en) → update config → all future operations use new language

## Critical Implementation Details

### Module Interfaces

**init.lua - `M.setup(opts)`**
- `opts`: table with `language` and `keymaps` keys
- Default: language="es", keymaps=true
- Registers keymaps if enabled

**fetch.lua - `M.fetch_scripture()` / `M.yank_scripture()`**
- No parameters, reads cursor line and config
- Side effects: spawns curl, displays tooltip, stores in register

**scripture.lua - `M.get_reference()` / `M.parse_reference(ref_string, language)`**
- Returns: {book, chapter, verses} or nil
- Validates against books mappings

**paste.lua - `M.paste_scripture()`**
- No parameters
- Reads register j, formats, inserts

**config.lua - `Config.get/set/setup()`**
- Manages language and keymaps settings
- Validates keys on write

**tooltip.lua - `M.show_verse_tooltip(ref_id, json)`**
- Displays floating window
- Strips HTML from jw.org response

**books.lua**
- Tables: `books.es` and `books.en`
- Maps: book name → canonical abbreviation
- Structure: 66 Bible books per language

**language_urls.lua - `LanguageURLs.get_url(language, ref_id)`**
- Returns formatted jw.org API URL
- Patterns differ for es/en

### Key Data Structures

**Reference Object** (from scripture.lua):
```lua
{
  book = "John",      -- normalized
  chapter = 3,
  verses = {
    {start = 16, end = 16},
    {start = 18, end = 18}
  }
}
```

**API Reference ID** (format): `{book_code}_{chapter}_{verse_start}-{verse_end}`
- Example: "43_3_16-18" (John 3:16-18)
- Book code: 1-66 (Genesis=1, Psalms=19, Matthew=40, John=43, etc.)

**jw.org JSON Response**:
```lua
{
  ranges = {
    ["43_3_16-18"] = {
      citation = "John 3:16-18",
      verses = {
        {content = "<p>16 For God loved...</p>"},
        {content = "<p>18 So the world...</p>"}
      }
    }
  }
}
```

**Register j Content**: `**Citation Text**\n\nVerse content line 1\nVerse content line 2`

### Async & Non-blocking

**HTTP Requests**:
- Execute via `vim.fn.jobstart(curl_cmd)` (non-blocking)
- Spinner displayed during request
- Completion via `on_exit` callback
- Results processed via `vim.schedule()` to ensure main loop

**Cookie Management**:
- Stored at `~/.config/jwtools/cookies.txt`
- Refreshed if > 1 hour old
- Auto-refresh triggered on next fetch if expired

### Configuration System

**Settings** (config.lua):
- `language`: "es" or "en" (default: "es")
- `keymaps`: boolean (default: true)

**Access**: `require("jwtools.config").get("language")`

**Update**: `require("jwtools.config").set("language", "en")`

**Runtime**: Can change language mid-session without restart

## Common Tasks & Code Patterns

### Adding a New Language

1. **Add to books.lua**:
   ```lua
   books.fr = {
     ["Genèse"] = "Gen",
     ["Genesis"] = "Gen",
     -- 66 Bible books with variants
   }
   ```

2. **Add to language_urls.lua**:
   ```lua
   url_patterns = {
     fr = "https://www.jw.org/fr/bibliotheque/.../json/html/%s",
   }
   ```

3. **Update init.lua**:
   ```lua
   local available_languages = { "es", "en", "fr" }
   ```

4. **Test**: Run with `<leader>jl`, fetch with new language

### Modifying Display Format

**Tooltip Display** (tooltip.lua):
- Edit `show_verse_tooltip()` function
- Change width (currently 60 chars)
- Adjust height (currently max 20 lines)
- Modify highlight group ("Normal" by default)

**Blockquote Format** (paste.lua):
- Edit `format_as_blockquote()` function
- Change line prefix (currently "> ")
- Adjust wrapping width calculation
- Modify citation formatting

### Handling New Response Format

If jw.org changes JSON structure:

1. **Update parsing** (fetch.lua):
   - `parse_response()` function reads JSON
   - Adjust key paths: `json.ranges[ref_id].citation`
   - Adjust verse extraction: `json.ranges[ref_id].verses[i].content`

2. **Update HTML stripping** (tooltip.lua):
   - Currently: `gsub("<[^>]+>", " ")`
   - Add special character handling if needed

3. **Test**: Verify tooltip and register format still work

## Testing & Validation

**Test Files Location**: `/tests/`

**Test Patterns**:
- `scripture_test.lua`: Reference parsing tests
- `books_test.lua`: Book mapping tests
- `paste_test.lua`: Formatting tests
- `debug_cursor.lua`: Cursor position debugging

**Run Tests**: Via Neovim (manual test setup, not automated CI)

## External Dependencies

### System
- **curl**: HTTP client (must be installed)
  - Used via `vim.fn.jobstart()`
  - Standard curl flags: `-s`, `-c`, `-H`, `--compressed`
  - Timeouts: `--max-time 10`

- **jw.org API**: Data source (must be online)
  - Spanish API: `jw.org/es/biblioteca/...`
  - English API: `jw.org/en/library/...`
  - Requires cookies for session

### Neovim
- **Version**: 0.5+ (uses Lua API)
- **APIs Used**:
  - `vim.fn.jobstart()` - async jobs
  - `vim.fn.getreg/setreg()` - register access
  - `vim.api.nvim_open_win()` - floating windows
  - `vim.keymap.set()` - keybinding
  - `vim.ui.select()` - interactive menu
  - `vim.notify()` - notifications

### Lua
- **Standard Library Only**: No external Lua libraries
- Functions used: `string.{find,sub,match,gsub,format}`, `table.{insert,concat}`, `tonumber`, `os.time()`

## Known Limitations

1. **Spanish book references**: Must use format without spaces (e.g., `1Cor 1:1`, not `1 Cor 1:1`)
2. **Single scripture per operation**: Cannot fetch multiple ranges in one command
3. **Limited book abbreviations**: Only recognized variants in mappings
4. **No range compression**: Multiple scriptures not combined into single fetch
5. **Hardcoded book mappings**: Cannot update without code change

## Code Style & Conventions

### Naming
- **Modules**: lowercase with underscores (e.g., `language_urls.lua`)
- **Functions**: camelCase for local, M.name for exports
- **Lua Variables**: lowercase with underscores
- **Constants**: UPPERCASE (e.g., `REGISTER = "j"`)

### Patterns
- **Return tables**: `return M` (Lua module pattern)
- **Error handling**: Notify users via `vim.notify()`, return nil on failure
- **Async patterns**: Use `vim.fn.jobstart()` with callbacks
- **Config access**: Always via `config.get()` / `config.set()`

### Comments
- Function headers explain parameters, return, side effects
- Lua annotations: `---@param`, `---@return` for LSP support
- Inline comments for complex logic only

## Debugging Tips

**Check Registration**:
```lua
-- In nvim, check keymaps:
:nmap <leader>jf
:vmap <leader>jp

-- Check config:
:lua print(require("jwtools.config").get("language"))
```

**Test Scripture Parsing**:
```lua
-- Call directly:
:lua require("jwtools.scripture").get_reference()

-- Should return table if line contains reference, nil otherwise
```

**Check Register**:
```lua
:reg j
-- Should show formatted scripture if fetch succeeded
```

**Test Fetch**:
```lua
-- Put cursor on "John 3:16" and press <leader>jf
-- Should show spinner, then tooltip
-- Check register j for stored content
```

**Cookie Issues**:
```bash
# Check cookie file:
cat ~/.config/jwtools/cookies.txt

# If empty or old, next fetch will refresh
```

## Performance Considerations

- **Lazy Loading**: Modules loaded on first use (not at startup)
- **Async HTTP**: Requests non-blocking, spinner provides feedback
- **Register Usage**: Stored reference enables multiple pastes without refetching
- **Cookie Caching**: Reused within 1-hour window (refresh only if needed)
- **Tooltip Display**: Auto-sized based on content (max 20 lines)

## File Modification Checklist

When editing files, ensure:

- [ ] Config changes validated in `config.lua`
- [ ] Book mappings complete for all 66 books per language
- [ ] API URLs tested and working in `language_urls.lua`
- [ ] Register format consistent across fetch/paste
- [ ] Keymaps properly registered in `init.lua`
- [ ] Error messages helpful via `vim.notify()`
- [ ] Async operations use `vim.schedule()` callbacks
- [ ] Comments explain parameters and side effects

## Additional Resources

- **Detailed Docs**: [.sop/summary/index.md](.sop/summary/index.md) - Comprehensive knowledge base
- **Architecture Details**: [.sop/summary/architecture.md](.sop/summary/architecture.md)
- **Module Documentation**: [.sop/summary/components.md](.sop/summary/components.md)
- **Workflow Diagrams**: [.sop/summary/workflows.md](.sop/summary/workflows.md)
- **API Reference**: [.sop/summary/interfaces.md](.sop/summary/interfaces.md)
- **Dependencies**: [.sop/summary/dependencies.md](.sop/summary/dependencies.md)

---

**Last Updated**: 2026-01-08
**Version**: 1.0
**For**: AI Code Assistants

This guide provides essential context for implementing features and fixing bugs. Refer to detailed documentation in `.sop/summary/` for comprehensive information on specific topics.
