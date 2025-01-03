# JW Tools

A plugin with helper tools to aide in the Bible Study using jw.org

## Installation

### Lazy

```lua
return {
  {
    cmd = {
      "JWToolsFetchScripture",
    },
    config = function()
      require("jwtools").setup()
    end,
    dir = "citosid/jwtools.nvim",
    keys = {
      { "<leader>jwf", "<cmd>JWToolsFetchScripture<cr>" },
    },
  },
}
```

## TODO

- [ ] Add multiple languages
- [ ] Ability to search for a word and insert an scripture
- [ ] Handle multiple scriptures in a row (for exammple `Ps 83:18; Rev 21:4`)
- [ ] Handle different abbreviations for the Bible books (i. e.: Ps. 83:18; Ps 83:18; Psalms 83:18)
- [ ] Add ability to play a portion of a book or the whole book

## Known Issues

- Currently only works for Spanish (although the scriptures should be written in English)
