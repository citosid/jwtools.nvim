# Bible Quote Refactoring Design - COMPLETED

## Status: COMPLETED

## Original Limitations
- Single verse parsing
- Inflexible book name matching (only recognized abbreviations)
- Missing singular forms (e.g., "Salmo" vs "Salmos")
- `get_book_number()` returning incorrect values

## Design Goals Achieved

### 1. Flexible Book Name Matching - COMPLETED
- Support multiple variations per book (full name, abbreviated, with/without dot)
- Handle singular/plural forms
- Maintain language-specific mappings

### 2. Book Number Resolution - COMPLETED
- Correct mapping of normalized abbreviations to biblical order (1-66)
- Proper lookup chain: variation -> normalized -> number

### 3. Error Handling - COMPLETED
- Returns `nil` for invalid book names
- Proper error propagation in scripture parsing

## Implemented Architecture

### Book Resolution Flow
```mermaid
graph TD
    A[Input: "Salmo 16:11"] --> B[Extract Book Name: "Salmo"]
    B --> C[resolve_book_name]
    C --> D{Found in book_variations?}
    D --> |Yes| E[Return normalized: "Sal"]
    D --> |No| F[Return nil]
    E --> G[get_book_number]
    G --> H[Lookup in book_numbers]
    H --> I[Return "19"]
```

### Data Structures

#### book_variations
Maps all book name variations to normalized abbreviations:
```lua
book_variations = {
    es = {
        ["Salmos"] = "Sal",
        ["Salmo"] = "Sal",
        ["Sal"] = "Sal",
        ["Sal."] = "Sal",
        -- ... all 66 books
    },
    en = { ... }
}
```

#### book_numbers
Maps normalized abbreviations to biblical order:
```lua
book_numbers = {
    es = {
        ["Sal"] = "19",
        ["Gén"] = "1",
        -- ... all 66 books
    },
    en = { ... }
}
```

## Technical Implementation
- Used Lua tables for efficient lookup
- Comprehensive book name dictionary for Spanish and English
- Clean separation between variation resolution and number lookup
- Unit tests for validation

## Files Modified
- `lua/jwtools/books.lua` - Core book mapping module
- `lua/jwtools/scripture.lua` - Scripture reference parsing
- `tests/books_test.lua` - Unit tests