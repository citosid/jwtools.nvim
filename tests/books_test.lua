-- Simple test runner for books module
-- Run with: nvim --headless -u NONE -c "set rtp+=." -c "luafile tests/books_test.lua" -c "qa!"

package.path = package.path .. ";./lua/?.lua;./lua/?/init.lua"

local books = require('jwtools.books')

local function assert_equals(actual, expected, message)
    if actual ~= expected then
        error(string.format("FAIL: %s\n  Expected: %s\n  Actual: %s", message, tostring(expected), tostring(actual)))
    else
        print(string.format("PASS: %s", message))
    end
end

local function assert_nil(actual, message)
    if actual ~= nil then
        error(string.format("FAIL: %s\n  Expected: nil\n  Actual: %s", message, tostring(actual)))
    else
        print(string.format("PASS: %s", message))
    end
end

print("\n=== Testing resolve_book_name (Spanish) ===")
assert_equals(books.resolve_book_name("Salmos", "es"), "Sal", "Salmos -> Sal")
assert_equals(books.resolve_book_name("Salmo", "es"), "Sal", "Salmo -> Sal")
assert_equals(books.resolve_book_name("Sal", "es"), "Sal", "Sal -> Sal")
assert_equals(books.resolve_book_name("Sal.", "es"), "Sal", "Sal. -> Sal")
assert_equals(books.resolve_book_name("Génesis", "es"), "Gén", "Génesis -> Gén")
assert_equals(books.resolve_book_name("Gén", "es"), "Gén", "Gén -> Gén")
assert_equals(books.resolve_book_name("Gén.", "es"), "Gén", "Gén. -> Gén")
assert_equals(books.resolve_book_name("Apocalipsis", "es"), "Apoc", "Apocalipsis -> Apoc")
assert_equals(books.resolve_book_name("Apoc", "es"), "Apoc", "Apoc -> Apoc")

print("\n=== Testing resolve_book_name (English) ===")
assert_equals(books.resolve_book_name("Psalms", "en"), "Ps", "Psalms -> Ps")
assert_equals(books.resolve_book_name("Ps", "en"), "Ps", "Ps -> Ps")
assert_equals(books.resolve_book_name("Ps.", "en"), "Ps", "Ps. -> Ps")
assert_equals(books.resolve_book_name("Genesis", "en"), "Gen", "Genesis -> Gen")
assert_equals(books.resolve_book_name("Gen", "en"), "Gen", "Gen -> Gen")
assert_equals(books.resolve_book_name("Gen.", "en"), "Gen", "Gen. -> Gen")
assert_equals(books.resolve_book_name("Revelation", "en"), "Rev", "Revelation -> Rev")
assert_equals(books.resolve_book_name("Rev", "en"), "Rev", "Rev -> Rev")

print("\n=== Testing get_book_number (Spanish) ===")
assert_equals(books.get_book_number("Salmos", "es"), "19", "Salmos -> 19")
assert_equals(books.get_book_number("Sal", "es"), "19", "Sal -> 19")
assert_equals(books.get_book_number("Sal.", "es"), "19", "Sal. -> 19")
assert_equals(books.get_book_number("Génesis", "es"), "1", "Génesis -> 1")
assert_equals(books.get_book_number("Gén", "es"), "1", "Gén -> 1")
assert_equals(books.get_book_number("Gén.", "es"), "1", "Gén. -> 1")
assert_equals(books.get_book_number("Apocalipsis", "es"), "66", "Apocalipsis -> 66")

print("\n=== Testing get_book_number (English) ===")
assert_equals(books.get_book_number("Psalms", "en"), "19", "Psalms -> 19")
assert_equals(books.get_book_number("Ps", "en"), "19", "Ps -> 19")
assert_equals(books.get_book_number("Ps.", "en"), "19", "Ps. -> 19")
assert_equals(books.get_book_number("Genesis", "en"), "1", "Genesis -> 1")
assert_equals(books.get_book_number("Gen", "en"), "1", "Gen -> 1")
assert_equals(books.get_book_number("Gen.", "en"), "1", "Gen. -> 1")
assert_equals(books.get_book_number("Revelation", "en"), "66", "Revelation -> 66")

print("\n=== Testing invalid inputs ===")
assert_nil(books.resolve_book_name("InvalidBook", "es"), "InvalidBook should return nil")
assert_nil(books.get_book_number("InvalidBook", "en"), "InvalidBook number should return nil")
assert_nil(books.resolve_book_name("Psalms", "fr"), "Unsupported language should return nil")

print("\n=== All tests passed! ===")