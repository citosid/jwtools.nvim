# JWTools Codebase Information

## Overview

**jwtools.nvim** is a Neovim plugin that provides Bible study tools with integration to JW.org, enabling scripture fetching, parsing, and insertion into documents across multiple languages.

## Project Metadata

- **Language**: Lua
- **Project Type**: Neovim Plugin
- **Package Manager**: Lazy (for plugin installation)
- **Testing Framework**: Custom Lua test scripts
- **Supported Languages**: Spanish (es), English (en)

## Directory Structure

```
jwtools.nvim/
├── lua/jwtools/           # Core plugin modules
│   ├── init.lua          # Main entry point, setup & keymaps
│   ├── config.lua        # Configuration management
│   ├── fetch.lua         # Scripture fetching from jw.org
│   ├── scripture.lua     # Scripture parsing & reference handling
│   ├── paste.lua         # Scripture insertion with formatting
│   ├── tooltip.lua       # Floating window tooltips for verses
│   ├── books.lua         # Bible book name mappings (es/en)
│   └── language_urls.lua # Language-specific API URL patterns
├── plugin/
│   └── jwtools.lua       # Plugin setup hook (minimal)
├── tests/                # Test files
│   ├── scripture_test.lua
│   ├── books_test.lua
│   ├── paste_test.lua
│   └── debug_cursor.lua
└── README.md             # User documentation
```

## Technology Stack

- **Neovim API**: Direct integration with Neovim's Lua API
- **HTTP Client**: curl (system command for fetching scripture)
- **JSON Processing**: Lua built-in parsing for jw.org JSON responses
- **Text Processing**: Lua string manipulation for verse parsing

## Key Dependencies

- **curl**: For HTTP requests to jw.org
- **Neovim**: v0.5+ (uses Lua API)
- **jw.org**: Data source for scripture content

## Architecture Patterns

1. **Module-based Organization**: Each feature is a separate Lua module with a simple API
2. **Lazy Loading**: Modules use lazy-loading metatable pattern in init.lua
3. **Configuration-driven**: Global language selection affects all operations
4. **Asynchronous Operations**: Uses Neovim's jobstart for non-blocking HTTP requests
5. **Register-based Data Flow**: Verse content stored in register "j" for clipboard operations

## Core Workflows

1. **Fetch Scripture**: Parse reference → validate → fetch from jw.org → display tooltip → store in register
2. **Yank Scripture**: Same as fetch but only stores in register (no tooltip)
3. **Paste Scripture**: Format stored scripture as blockquote → insert at cursor
4. **Language Selection**: Interactive menu to switch between es/en configurations

## External APIs

- **jw.org JSON API** (Spanish): `https://www.jw.org/{lang}/biblioteca/biblia/biblia-estudio/libros/json/html/{ref_id}`
- **jw.org JSON API** (English): `https://www.jw.org/{lang}/library/bible/study-bible/books/json/html/{ref_id}`

## Configuration Points

- **language**: Active language (es/en) - default: es
- **keymaps**: Enable default keymaps - default: true

## Known Limitations

- Spanish requires scriptures without spaces (e.g., `1Cor 1:1` not `1 Cor 1:1`)
- Single scripture per operation (no multiple ranges in one command)
- Limited Bible book abbreviation variants
