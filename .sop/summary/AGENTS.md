# JWTools.nvim AI Coding Assistant Guide

## Project Overview
Neovim plugin for Bible study tools, focusing on scripture retrieval from JW.org.

## Architectural Insights
- Modular Lua architecture
- Lazy-loaded plugin design
- Multilingual support mechanism
- Asynchronous processing

## Key Modules for AI Focus
1. `init.lua`: Plugin initialization and setup
2. `fetch.lua`: Core scripture retrieval logic
3. `language_urls.lua`: Multilingual URL generation
4. `scripture.lua`: Reference parsing

## Development Priorities
- Improve multilingual support
- Enhance reference parsing
- Implement advanced search capabilities
- Add error handling and edge case management

## Coding Conventions
- Use Lua's module pattern
- Implement lazy loading
- Prefer asynchronous operations
- Utilize Vim API for UI integration

## Contribution Guidelines
- Maintain modular design
- Add comprehensive error handling
- Write clear, documented functions
- Support multiple languages
- Optimize performance

## Performance Considerations
- Use asynchronous job handling
- Minimize synchronous blocking operations
- Implement efficient caching mechanisms
- Optimize URL and scripture fetching

## Future Enhancements
- Advanced scripture search
- Multiple reference handling
- Flexible book abbreviation support
- Audio playback integration

## Testing Strategy
- Unit test individual module functions
- Integration test scripture fetching
- Language-specific test cases
- Error handling validation

## Design Patterns
- Singleton configuration management
- Lazy module loading
- Separation of concerns
- Functional programming principles
