# JWTools Documentation Index

**Purpose**: Knowledge base index for AI coding assistants working with the jwtools.nvim plugin.

This index provides a curated guide to all documentation files, helping assistants quickly locate relevant information for different types of questions and tasks.

## Quick Reference

| Question Type | Primary File | Secondary Files |
|---|---|---|
| How does feature X work? | [workflows.md](#workflows) | [components.md](#components) |
| What does module Y do? | [components.md](#components) | [architecture.md](#architecture) |
| How do I modify X? | [components.md](#components) + [interfaces.md](#interfaces) | [architecture.md](#architecture) |
| What external dependencies exist? | [dependencies.md](#dependencies) | [codebase_info.md](#codebase-info) |
| How do I add language support? | [interfaces.md](#interfaces) | [components.md](#components), [workflows.md](#workflows) |
| What's the data flow for feature X? | [workflows.md](#workflows) | [architecture.md](#architecture) |
| Where is code for X? | [codebase_info.md](#codebase-info) | [components.md](#components) |

## Documentation Files

### codebase_info.md {#codebase-info}

**Purpose**: High-level overview of project structure and technology stack

**Content**:
- Project metadata (language, type, dependencies)
- Directory structure with file purposes
- Technology stack overview
- Key external APIs
- Configuration system
- Known limitations

**Use When**:
- Getting overview of the project
- Finding where files are located
- Understanding technology choices
- Learning about supported languages
- Identifying system limitations

**Key Sections**:
- Project Metadata: Language, type, testing framework
- Directory Structure: Visual tree with file purposes
- Technology Stack: Neovim API, curl, JSON
- External APIs: jw.org endpoints and behavior
- Configuration Points: What can be customized

---

### architecture.md {#architecture}

**Purpose**: System design, component relationships, and data flow patterns

**Content**:
- System architecture diagram (flowchart)
- Component interaction flow
- Design principles (modularity, Lua-first, async patterns, config centralization)
- Data flow patterns (register-based, async request handling)
- Extension points for customization
- API integration with jw.org

**Use When**:
- Understanding how components work together
- Learning the overall system design
- Identifying design patterns used
- Planning modifications to architecture
- Understanding async request handling
- Adding new features or languages

**Key Diagrams**:
- System Architecture Overview: Shows all components and their relationships
- Component Interaction Flow: Fetch and paste workflows
- Extension Points: How to customize/extend

**Key Concepts**:
- Module-based organization with lazy loading
- Non-blocking async operations via jobstart
- Register-based data communication
- Centralized configuration management

---

### components.md {#components}

**Purpose**: Detailed description of each module, functions, and responsibilities

**Content**:
- 8 core modules with detailed descriptions
- Function signatures and purposes
- Configuration management
- Data structures used
- Error handling approaches
- Module dependency relationships

**Modules Documented**:
1. `init.lua` - Plugin initialization & keymaps
2. `config.lua` - Configuration management
3. `fetch.lua` - Scripture fetching & HTTP
4. `scripture.lua` - Reference parsing
5. `paste.lua` - Scripture insertion & formatting
6. `tooltip.lua` - Floating window display
7. `books.lua` - Bible book name mappings
8. `language_urls.lua` - API endpoint configuration

**Use When**:
- Need to understand what a specific module does
- Looking for function signatures
- Understanding data structures
- Finding where specific functionality lives
- Planning module modifications
- Learning about module dependencies

**Key Reference Sections**:
- Core Modules Overview: 8 detailed module descriptions
- Module Dependencies: Dependency graph and relationships
- Data Structures: Reference objects, tooltip data format
- Error Handling: Common error cases and approaches

---

### interfaces.md {#interfaces}

**Purpose**: External APIs, function signatures, and integration points

**Content**:
- User-facing commands
- Complete module interface documentation
- External jw.org API specification
- Neovim API usage patterns
- Data format specifications
- Integration points for extension

**API Reference**:
- Plugin setup and configuration interface
- Module function signatures with parameters/returns
- jw.org JSON API endpoint details
- Neovim Lua API usage examples
- Register content format specification
- Reference ID format for API

**Use When**:
- Need exact function signatures
- Looking up parameter requirements
- Understanding return values
- Learning about Neovim API usage
- Planning integrations
- Understanding data format specifications
- Adding language support

**Key Sections**:
- Plugin Interface: User commands
- Module Interfaces: Complete API for each module
- External API: jw.org JSON API specification
- Neovim API Usage: Examples of vim.* calls
- Data Format Specs: Register format, Reference IDs
- Integration Points: How to extend functionality

---

### workflows.md {#workflows}

**Purpose**: Step-by-step descriptions of user workflows and data flows

**Content**:
- 5 major user workflows with sequence diagrams
- Detailed step-by-step procedures
- Error handling flows
- State transitions
- Data transformation pipelines
- Mermaid sequence diagrams showing interactions

**Workflows Documented**:
1. Fetch and Display Scripture (jf): Parse → fetch → display → store
2. Yank Scripture (jy): Parse → fetch → store (no display)
3. Paste Scripture (jp): Format → insert blockquote
4. Language Selection (jl): Interactive menu → update config
5. Plugin Setup: Initialization and keymap registration

**Use When**:
- Understanding what happens when user performs an action
- Debugging workflow issues
- Tracing data flow through system
- Understanding async operations
- Learning error handling behavior
- Planning feature modifications
- Understanding state transitions

**Key Features**:
- Sequence diagrams for visual understanding
- Step-by-step numbered procedures
- Example output formats
- Error case handling
- State transition diagrams
- Data transformation visualizations

---

### dependencies.md {#dependencies}

**Purpose**: External and internal dependencies, compatibility, and risk assessment

**Content**:
- System dependencies (curl, jw.org)
- Internal module dependencies with graph
- Lua standard library usage
- Neovim Lua API usage patterns
- Cookie management system
- Dependency compatibility matrix
- Risk assessment for each dependency

**Dependency Categories**:
- System: curl, jw.org service
- Module: Internal Lua modules and their relationships
- Lua: Standard library functions used
- Neovim: Lua API calls and their purposes
- Data: Book mappings, API formats, JSON structure

**Use When**:
- Understanding external dependencies
- Assessing compatibility requirements
- Planning installations
- Debugging missing dependencies
- Understanding cookie management
- Evaluating risk of API changes
- Planning future changes

**Key Sections**:
- External Dependencies: curl, jw.org
- Internal Dependencies: Module relationships
- Dependency Compatibility: Version and OS support
- Risk Assessment: Critical vs. non-critical dependencies
- Data Dependencies: Book mappings, API format

---

## Common Task Workflows

### Task: Add a New Language

1. Consult **[components.md](#components)** - `books.lua` section for mapping structure
2. Consult **[components.md](#components)** - `language_urls.lua` section for URL pattern
3. Consult **[interfaces.md](#interfaces)** - Integration Points section
4. Check **[workflows.md](#workflows)** - Fetch workflow to understand parsing
5. Implement mappings and test against **[workflows.md](#workflows)** - Workflow 1

### Task: Modify Scripture Display

1. Consult **[components.md](#components)** - `tooltip.lua` and `paste.lua` sections
2. Check **[workflows.md](#workflows)** - Fetch Workflow (tooltip display step)
3. Review **[interfaces.md](#interfaces)** - Neovim API Usage for window creation
4. Examine **[architecture.md](#architecture)** - Extension Points for UI customization

### Task: Debug Fetch Not Working

1. Check **[workflows.md](#workflows)** - Workflow 1: Fetch and Display Scripture
2. Review **[components.md](#components)** - `fetch.lua` error handling section
3. Consult **[dependencies.md](#dependencies)** - External Dependencies (curl, jw.org)
4. Check **[dependencies.md](#dependencies)** - Cookie Management section

### Task: Change Keymap Behavior

1. Consult **[components.md](#components)** - `init.lua` - Default Keymaps section
2. Review **[interfaces.md](#interfaces)** - User-Facing Commands
3. Check **[workflows.md](#workflows)** - Appropriate workflow for the command

### Task: Understand Register Format

1. Check **[interfaces.md](#interfaces)** - Data Format Specifications - Register Format
2. Review **[workflows.md](#workflows)** - Workflow 3: Paste Scripture
3. Consult **[components.md](#components)** - `paste.lua` for formatting logic

### Task: Add HTTP Error Handling

1. Review **[workflows.md](#workflows)** - Error Handling Flows section
2. Consult **[components.md](#components)** - `fetch.lua` - Async Handling section
3. Check **[dependencies.md](#dependencies)** - External Dependencies (curl)

## Project Statistics

- **Total Modules**: 8 Lua modules
- **Total Lines of Code**: ~1,400 (estimated)
- **Core Files**: 8 (in `lua/jwtools/`)
- **Plugin Hook**: 1 (in `plugin/`)
- **Test Files**: 4 (in `tests/`)
- **Supported Languages**: 2 (Spanish, English)
- **Bible Books Mapped**: 66 per language

## Key Concepts to Understand

### Lazy Loading
- Modules loaded on first access via metatable `__index` in `init.lua`
- Improves startup performance
- See [components.md - init.lua](#components)

### Async HTTP Requests
- Curl requests execute in background via `vim.fn.jobstart()`
- Results processed via `vim.schedule()` callback
- Spinner animation provides visual feedback
- See [workflows.md - Fetch Workflow](#workflows)

### Register-based Data Flow
- Verses stored in register "j" (clipboard register)
- Format: `**Citation**\n\nVerse content`
- Enables pass-through: fetch → paste
- See [interfaces.md - Register Format](#interfaces)

### Configuration Management
- Single `config.lua` manages all settings
- Language and keymap settings
- Runtime modification without restart
- See [components.md - config.lua](#components)

### Cookie Management
- Session cookies from jw.org stored at `~/.config/jwtools/cookies.txt`
- Auto-refresh if > 1 hour old
- Essential for API requests
- See [dependencies.md - Cookie Management](#dependencies)

## Documentation Metadata

| File | Size | Sections | Key Diagrams |
|---|---|---|---|
| codebase_info.md | Small | 7 | None |
| architecture.md | Medium | 6 | 3 Mermaid diagrams |
| components.md | Large | 11 | 1 Mermaid diagram |
| interfaces.md | Large | 7 | Code examples |
| workflows.md | Large | 8 | 8 Mermaid diagrams |
| dependencies.md | Medium | 8 | 1 Mermaid diagram |

## Using This Documentation

### For Code Understanding
1. Start with **[codebase_info.md](#codebase-info)** for overview
2. Move to **[architecture.md](#architecture)** to understand design
3. Consult **[components.md](#components)** for specific module details
4. Reference **[workflows.md](#workflows)** to understand execution flows

### For Implementation Tasks
1. Identify affected modules in **[components.md](#components)**
2. Review workflows in **[workflows.md](#workflows)**
3. Check interfaces in **[interfaces.md](#interfaces)**
4. Verify dependencies in **[dependencies.md](#dependencies)**

### For Debugging Issues
1. Find relevant workflow in **[workflows.md](#workflows)**
2. Check component details in **[components.md](#components)**
3. Review error handling in **[dependencies.md](#dependencies)**
4. Verify API contracts in **[interfaces.md](#interfaces)**

### For Adding Features
1. Review architecture in **[architecture.md](#architecture)** - Extension Points
2. Find affected modules in **[components.md](#components)**
3. Understand data flow in **[workflows.md](#workflows)**
4. Check integration points in **[interfaces.md](#interfaces)**
5. Verify dependencies in **[dependencies.md](#dependencies)**

## File Relationships

```
codebase_info.md (Overview)
    ↓
architecture.md (System Design)
    ├→ components.md (Module Details)
    ├→ workflows.md (Execution Flows)
    └→ interfaces.md (APIs)
    
dependencies.md (Supports all above)
```

---

**Last Updated**: 2026-01-08
**Documentation Version**: 1.0
**Codebase**: jwtools.nvim
