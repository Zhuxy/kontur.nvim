# kontur.nvim

## Intro

`kontur.nvim` provides powerful and intuitive text objects to select and operate on blocks of text based on their structure. It understands both code indentation, Markdown-style headings and simple prefix pattern, allowing you to work with logical blocks seamlessly.

The basic concept is to select neighboring lines of text base on the indent level under the cursor.

When searching the lines, the operation means all the neighboring lines whose indent level is equal or lower than the line under the cursor.

Including any empty line when searching.

UPDATE:

Now we can select content by Markdown heading level.

Using `vih` to select all lines under the nearest Markdown heading.

UPDATE 2:

Now we can select lines which have the save prefix pattern (the leftmost non-whitespace characters). E.g. all lines with a comment pattern `// ` can be selected by `vip`. And also it support numbered lists, like `1. `, `2. `, ...,  `10. `, `11. `.

## Config

The default keystroke for indent line is `i`. If you want to use another character, you can set the config object:

```lua
require("kontur").setup({
    indent_object_char = 'i', -- now use `ii` to select by indent
    heading_object_char = 'h', -- now use `ih` to select by markdown heading
    prefix_object_char = 'p', -- now use `ip` to select by prefix pattern
})
```

## Usage

Here is a function:

```lua
 local function test()
   print(1)
   print(2)     <-- cursor here
   print(3)
 end
```

use `vii` to select function body (They all have the same indent level):

```lua
 local function test()
█  print(1)
█  print(2)
█  print(3)
 end
```

Here are some markdown texts:

```markdown
 # Header 1
 - List 1
   - Sub list 1
   - Sub list 2     <-- cursor here
   - Sub list 3
 
 # Header 2
```

use `vii` to select sub lists (without the empty line):

```markdown
 # Header 1
 - List 1
█  - Sub list 1
█  - Sub list 2
█  - Sub list 3
 
 # Header 2
```

## Select by Markdown headings

Here are some markdown texts: 

```Markdown
 # Header 1
 - List 1
   - Sub list 1
   - Sub list 2     <-- cursor here
   - Sub list 3
 
 # Header 2
```

use `vih` to select all lines under the nearest Markdown heading:

```Markdown
 # Header 1
█- List 1
█  - Sub list 1
█  - Sub list 2
█  - Sub list 3
 

 # Header 2
```

## Select by prefix pattern

Here are some code with comments (same pattern, start with `// `):

```
 let a = 42;
 // This is a comment
 // This is another comment      <-- cursor here
 // And one more
 print(a);
```

use `vip` to select the comment block 

```
let a = 42;
█// This is a comment
█// This is another comment      <-- cursor here
█// And one more
print(a);
```

Or you can select the numbered list:

```
 1. First item
 2. Second item
 3. Third item             <-- cursor here
 ...
 11. Eleven item
```

use `vip` to select the numbered list:

```
█1. First item
█2. Second item
█3. Third item
█...
█11. Eleven item 
```
