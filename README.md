# kontur.nvim

## Intro

`kontur.nvim` provides powerful and intuitive text objects to select and operate on blocks of text based on their structure. It understands code indentation, Markdown-style headings, repeatable prefix patterns, and Markdown tables, allowing you to work with logical blocks seamlessly.

The basic concept is to select neighboring lines of text base on the indent level under the cursor.

When searching the lines, the operation means all the neighboring lines whose indent level is equal or lower than the line under the cursor.

Including any empty line when searching.

UPDATE:

Now we can select content by Markdown heading level.

Using `vih` to select all lines under the nearest Markdown heading, and `vah` to include the heading line itself.

UPDATE 2:

Now we can select lines which share the same repeatable prefix pattern, meaning the same leftmost non-whitespace marker. `r` stands for repeatable prefix pattern. For example, all lines with a comment prefix `// ` can be selected by `vir`. It also supports numbered lists such as `1. `, `2. `, ..., `10. `, `11. `.

UPDATE 3:

Now we can select a Markdown pipe table with `vit`. The selector works from the header row, delimiter row, or any body row.

## Config

The default keystroke for indent line is `i`. If you want to use another character, you can set the config object:

```lua
require("kontur").setup({
    indent_object_char = 'i', -- now use `ii` to select by indent
    heading_object_char = 'h', -- now use `ih` to select by markdown heading
    prefix_object_char = 'r', -- now use `ir` to select by repeatable prefix pattern
    table_object_char = 't', -- now use `it` to select by markdown table
})
```

## Usage

### Select by indent

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

### Select by Markdown headings

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

use `vah` to select the heading and all its content, trimming trailing blank lines:

```Markdown
█# Header 1
█- List 1
█  - Sub list 1
█  - Sub list 2
█  - Sub list 3

 # Header 2
```

### Select by repeatable prefix pattern

Here is some code with comments that share the same repeatable prefix pattern, `// `:

```
 let a = 42;
 // This is a comment
 // This is another comment      <-- cursor here
 // And one more
 print(a);
```

use `vir` to select the comment block:

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
 11. Eleventh item
```

use `vir` to select the numbered list:

```
█1. First item
█2. Second item
█3. Third item
█...
█11. Eleventh item 
```

### Select by Markdown table

Here is a Markdown pipe table:

```markdown
Before

| Name | Align | Count |
| --- | :---: | ---: |
| Ada | mid | 1 |       <-- cursor here
| Linus | low | 2 |

After
```

use `vit` to select the whole table:

```markdown
Before

█| Name | Align | Count |
█| --- | :---: | ---: |
█| Ada | mid | 1 |
█| Linus | low | 2 |

After
```
