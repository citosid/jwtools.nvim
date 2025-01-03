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

- [x] Add multiple languages
- [x] Add loading spinner to show something is happenning
- [ ] Ability to search for a word and insert an scripture
- [ ] Handle multiple scriptures in a row (for exammple `Ps 83:18; Rev 21:4`)
- [ ] Handle different abbreviations for the Bible books (i. e.: Ps. 83:18; Ps 83:18; Psalms 83:18)
- [ ] Add ability to play a portion of a book or the whole book

## Known Issues

- Spanish scriptures now need to have the scripture as a single word. For example, 1 Cor 1:1 will not work. But
  1Cor 1:1 will Gál 1:1
