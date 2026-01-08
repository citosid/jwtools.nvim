# Components

## Core Modules Overview

### 1. init.lua - Plugin Initialization
**Purpose**: Entry point for plugin, manages setup, keymaps, and lazy-loading

**Key Functions**:
- `M.setup(opts)`: Initializes plugin with user config
- `M.select_language()`: Interactive language selector
- Lazy-loads modules on first access via `__index` metatable

**Configuration Options**:
- `language`: Target language (es/en), default: es
- `keymaps`: Enable default keymaps, default: true

**Default Keymaps**:
- `<leader>jf`: Fetch scripture (tooltip + yank)
- `<leader>jy`: Yank scripture to register
- `<leader>jp`: Paste scripture as blockquote
- `<leader>jl`: Select language

**Responsibilities**:
- Load configuration
- Register keymaps
- Initialize lazy-loaded modules

### 2. config.lua - Configuration Management
**Purpose**: Centralized settings management

**Key Functions**:
- `Config.setup(opts)`: Merge user options into defaults
- `Config.get(key)`: Retrieve configuration value
- `Config.set(key, value)`: Update configuration value

**Settings Stored**:
- `language`: Active language string
- `keymaps`: Boolean flag for keymap registration

**Behavior**:
- Validates keys on set/setup
- Notifies on invalid keys
- Defaults: language="es", keymaps=true

### 3. fetch.lua - Scripture Fetching & Parsing
**Purpose**: Handle HTTP requests to jw.org and coordinate scripture retrieval

**Key Functions**:
- `M.fetch_scripture()`: Parse → fetch → display → store (main user entry)
- `M.yank_scripture()`: Parse → fetch → store (no display)
- `refresh_cookies()`: Maintain jw.org session cookies
- `show_spinner()`: Animated loading indicator
- `get_scripture_reference()`: Extract reference from current line

**Workflow**:
1. Parse scripture reference from line at cursor
2. Validate against book mappings
3. Ensure valid cookies (refresh if needed)
4. Build API URL with language-specific pattern
5. Execute curl request asynchronously
6. On success: Display tooltip + store in register
7. On failure: Notify user

**Cookie Management**:
- Stored at `~/.config/jwtools/cookies.txt`
- Refreshed if older than 1 hour
- Triggered on first fetch or expired

**Async Handling**:
- Uses `vim.fn.jobstart()` for non-blocking curl
- Spinner animates while waiting
- Results processed via `vim.schedule()`

### 4. scripture.lua - Reference Parsing
**Purpose**: Parse and validate Bible book references from text

**Key Functions**:
- `M.get_reference()`: Extract reference from line
- `M.parse_reference()`: Convert text reference to API ref_id
- `parse_chapter_verses()`: Handle chapter:verse syntax
- `merge_consecutive_verses()`: Optimize verse ranges

**Features**:
- Handles multiple book name variations
- Supports verse ranges (e.g., 1-5, 10-15)
- Merges consecutive verses into ranges
- Normalizes non-breaking spaces
- Supports comma and semicolon separated verses

**Supported Formats**:
- Single verse: "John 3:16"
- Verse range: "John 3:16-18"
- Multiple verses: "John 3:16, 18, 20-22"
- Multiple chapters: "John 3:16; 4:1-5"

**Output**: API ref_id suitable for jw.org JSON endpoint

### 5. paste.lua - Scripture Insertion & Formatting
**Purpose**: Format and insert scripture into buffer

**Key Functions**:
- `M.paste_scripture()`: Insert stored scripture at cursor
- `format_as_blockquote()`: Convert register content to markdown
- `wrap_text()`: Apply text wrapping respecting word boundaries

**Formatting**:
- Parses stored format: `**Citation**\n\nContent`
- Wraps citation as blockquote header
- Wraps verse content to `textwidth` (or 80)
- Adds `> ` prefix to each line

**Behavior**:
- Normal mode: Insert at cursor (new lines)
- Visual mode: Replace selection with blockquote
- Respects `textwidth` buffer option
- Preserves word integrity in wrapping

### 6. tooltip.lua - UI Display
**Purpose**: Render formatted verses in floating window

**Key Functions**:
- `M.show_verse_tooltip()`: Display verse in floating window
- HTML stripping for verse content
- Line wrapping (60 char default)

**Features**:
- Strips HTML tags from jw.org content
- Normalizes whitespace
- Centers window above/below cursor
- Auto-sizes based on content (max height: 20 lines)
- Displays with "Normal" highlight group

### 7. books.lua - Book Name Mapping
**Purpose**: Map various book name formats to canonical abbreviations

**Structure**:
- Separate mappings for Spanish (es) and English (en)
- Maps full names, abbreviations, and variants to canonical form
- Provides canonical name → API reference ID mapping

**Supported Variants** (example - Spanish):
- Full name: "Génesis" → Gén
- Abbreviation: "Gén" → Gén
- With period: "Gén." → Gén
- Numeric prefix: "1 Samuel" → 1Sam, "1Samuel" → 1Sam

**Functions**:
- `books_es`: Spanish book mappings
- `books_en`: English book mappings
- Returns normalized reference ID for API

### 8. language_urls.lua - API Endpoint Configuration
**Purpose**: Provide language-specific jw.org API URLs

**Structure**:
```lua
url_patterns = {
  es = "https://www.jw.org/%s/biblioteca/biblia/biblia-estudio/libros/json/html/%s",
  en = "https://www.jw.org/%s/library/bible/study-bible/books/json/html/%s",
}
```

**Function**:
- `get_url(language, ref_id)`: Return formatted API URL

**Usage**: Called by fetch.lua to construct HTTP request URLs

## Module Dependencies

```
init.lua (entry point)
  ├─ config.lua
  ├─ fetch.lua
  │   ├─ scripture.lua
  │   ├─ language_urls.lua
  │   ├─ tooltip.lua
  │   └─ config.lua
  └─ paste.lua
  
scripture.lua
  └─ books.lua (for reference validation)
  └─ config.lua (for language)

tooltip.lua
  (standalone text formatting)

books.lua
  (standalone data)

language_urls.lua
  └─ config.lua (for language selection)
```

## Data Structures

### Reference Object
```lua
{
  book = "John",           -- Normalized book name
  chapter = 3,             -- Chapter number
  verses = {               -- Array of verse ranges
    { start = 16, end = 16 },
    { start = 18, end = 20 }
  }
}
```

### Tooltip Data
```lua
{
  citation = "John 3:16",
  verses = {
    { content = "16 Verse text..." },
    { content = "17 Next verse..." }
  }
}
```

## Error Handling

- Invalid book names: Notify user and abort
- Invalid chapter/verse: Notify user and abort
- Network failures: Retry with cookie refresh, then notify
- Missing register content: Warn user before paste
- Cookie expiration: Auto-refresh on next request
