# Volt API Reference

Complete technical reference for the Volt framework.

## Table of Contents

- [Core API](#core-api)
- [UI Components](#ui-components)
- [Event System](#event-system)
- [Color Utilities](#color-utilities)
- [State Management](#state-management)
- [Utilities](#utilities)
- [Type Definitions](#type-definitions)

## Core API

### `volt` Module

Main entry point for Volt functionality.

```lua
local volt = require("volt")
```

---

#### `volt.gen_data(config)`

Generate UI state and calculate layout positions for buffers.

**Parameters:**
- `config` (table[]): Array of buffer configurations

**Config Structure:**
```lua
{
  buf = number,      -- Buffer ID
  layout = table,    -- Layout definition (see Layout Structure)
  ns = number,       -- Namespace ID from nvim_create_namespace()
  xpad = number      -- Horizontal padding (optional, default: 0)
}
```

**Layout Structure:**
```lua
{
  {
    name = string,                    -- Section identifier
    row = number,                     -- Starting row (auto-calculated)
    col_start = number,               -- Column offset (optional)
    lines = function(buf) -> table    -- Function returning line data
  },
  -- ... more sections
}
```

**Line Data Format:**
```lua
{
  { 
    { "text", "HighlightGroup" },
    { "more text", "AnotherHL" },
    { "clickable", "HL", callback_function }
  },
  -- ... more lines
}
```

**Example:**
```lua
volt.gen_data({
  {
    buf = my_buf,
    layout = {
      {
        name = "header",
        lines = function(buf)
          return {
            { { "Title", "Title" } }
          }
        end
      }
    },
    ns = vim.api.nvim_create_namespace("my_ns"),
    xpad = 2
  }
})
```

---

#### `volt.run(buf, opts)`

Render UI to buffer and initialize event system.

**Parameters:**
- `buf` (number): Buffer ID
- `opts` (table): Configuration options

**Options:**
```lua
{
  h = number,                        -- Height in lines
  w = number,                        -- Width in columns
  custom_empty_lines = function,     -- Optional: custom line setup function
  winclosed_event = boolean          -- Auto-close on WinClosed (default: false)
}
```

**Example:**
```lua
volt.run(buf, {
  h = 30,
  w = 80,
  winclosed_event = true
})
```

---

#### `volt.redraw(buf, sections)`

Update specific sections of the UI.

**Parameters:**
- `buf` (number): Buffer ID
- `sections` (string|string[]|"all"): Section(s) to redraw

**Examples:**
```lua
-- Single section
volt.redraw(buf, "header")

-- Multiple sections
volt.redraw(buf, { "header", "content", "footer" })

-- All sections
volt.redraw(buf, "all")
```

---

#### `volt.set_empty_lines(buf, n, w)`

Create empty lines in buffer for rendering.

**Parameters:**
- `buf` (number): Buffer ID
- `n` (number): Number of lines
- `w` (number): Width of each line

**Example:**
```lua
volt.set_empty_lines(buf, 30, 80)
```

---

#### `volt.mappings(config)`

Setup default keymaps for Volt buffers.

**Parameters:**
- `config` (table): Mapping configuration

**Config:**
```lua
{
  bufs = number[],           -- Array of buffer IDs
  winclosed_event = boolean  -- Enable WinClosed autocmd (optional)
}
```

**Default Mappings:**
- `<CR>`: Activate element under cursor
- `<Tab>`: Next clickable element
- `<S-Tab>`: Previous clickable element
- `q`: Close UI
- `<Esc>`: Close UI
- `<C-t>`: Cycle buffers (if multiple)

**Example:**
```lua
volt.mappings({
  bufs = { buf1, buf2 },
  winclosed_event = true
})
```

---

#### `volt.toggle_func(open_fn, state)`

Helper for UI toggle functionality.

**Parameters:**
- `open_fn` (function): Function to open UI
- `state` (boolean): Current UI state

**Example:**
```lua
local is_open = false

function toggle_ui()
  volt.toggle_func(open_ui, is_open)
  is_open = not is_open
end
```

---

#### `volt.close(buf?)`

Close UI buffer and cleanup.

**Parameters:**
- `buf` (number|nil): Buffer ID (optional, uses current buffer if nil)

**Example:**
```lua
volt.close(buf)
-- or
volt.close() -- closes current buffer
```

---

## UI Components

### `volt.ui` Module

Pre-built UI components.

```lua
local ui = require("volt.ui")
```

---

### `ui.checkbox(opts)`

Create a checkbox component.

**Parameters:**
- `opts` (CheckboxOptions)

**CheckboxOptions:**
```lua
{
  active = boolean,        -- Current state
  txt = string,            -- Label text
  check = string,          -- Checked icon (default: "")
  uncheck = string,        -- Unchecked icon (default: "")
  hlon = string,           -- Active highlight (default: "String")
  hloff = string,          -- Inactive highlight (default: "ExInactive")
  actions = function       -- Click handler (optional)
}
```

**Returns:** `table` - Virtual text line

**Example:**
```lua
local checkbox = ui.checkbox({
  active = true,
  txt = "Enable feature",
  check = "✓",
  uncheck = "✗",
  hlon = "String",
  hloff = "Comment",
  actions = function()
    print("Toggled!")
  end
})
```

---

### `ui.slider.config(opts)`

Create a slider component.

**Parameters:**
- `opts` (SliderOptions)

**SliderOptions:**
```lua
{
  txt = string,            -- Label text (optional)
  val = number,            -- Current value (0-100)
  w = number,              -- Width
  hlon = string,           -- Active highlight
  hloff = string,          -- Inactive highlight (optional)
  thumb = boolean,         -- Show thumb indicator (optional)
  thumb_icon = string,     -- Custom thumb icon (optional, default: "")
  ratio_txt = boolean,     -- Show percentage (optional)
  actions = function       -- Value change handler
}
```

**Returns:** `table` - Virtual text line

**Example:**
```lua
local slider = ui.slider.config({
  txt = "Volume: ",
  val = 50,
  w = 40,
  hlon = "String",
  hloff = "Comment",
  thumb = true,
  ratio_txt = true,
  actions = function()
    local new_val = ui.slider.val(40, "Volume: ", 2)
    print("New value:", new_val)
  end
})
```

---

### `ui.slider.val(w, left_txt, xpad, opts?)`

Get slider value from cursor position.

**Parameters:**
- `w` (number): Slider width
- `left_txt` (string): Label text
- `xpad` (number): Horizontal padding
- `opts` (table|nil): Options `{ thumb = boolean, ratio = boolean }`

**Returns:** `number` - Value (0-100)

**Example:**
```lua
local value = ui.slider.val(40, "Volume: ", 2, { thumb = true })
```

---

### `ui.progressbar(opts)`

Create a progress bar.

**Parameters:**
- `opts` (ProgressOptions)

**ProgressOptions:**
```lua
{
  w = number,              -- Width
  val = number,            -- Progress (0-100)
  icon = {                 -- Icon configuration (optional)
    on = string,           -- Active icon (default: "-")
    off = string           -- Inactive icon (default: "-")
  },
  hl = {                   -- Highlight configuration (optional)
    on = string,           -- Active hl (default: "exred")
    off = string           -- Inactive hl (default: "linenr")
  }
}
```

**Returns:** `table[]` - Two-element array: `{ active_part, inactive_part }`

**Example:**
```lua
local progress = ui.progressbar({
  w = 30,
  val = 65,
  icon = { on = "━", off = "─" },
  hl = { on = "String", off = "Comment" }
})
```

---

### `ui.separator(char?, w, hl?)`

Create a horizontal separator line.

**Parameters:**
- `char` (string|nil): Character to use (default: "─")
- `w` (number): Width
- `hl` (string|nil): Highlight group (default: "linenr")

**Returns:** `table[]` - Single-element line array

**Example:**
```lua
local sep = ui.separator("─", 50, "Comment")
```

---

### `ui.table(data, w, header_hl?, title?)`

Create a formatted table with borders.

**Parameters:**
- `data` (table[][]): 2D array of table data
- `w` (number|"fit"): Total width or "fit" for auto-width
- `header_hl` (string|nil): Header row highlight (optional)
- `title` (table|nil): Title virtual text (optional)

**Returns:** `table[]` - Array of table lines

**Example:**
```lua
local tbl = ui.table(
  {
    { "Name", "Age", "City" },
    { "Alice", "25", "NYC" },
    { "Bob", "30", "LA" }
  },
  60,
  "Title",
  { "Users", "Title" }
)
```

**Complex Cells:**
```lua
local tbl = ui.table({
  { "Name", "Status" },
  { 
    "Alice",
    { { "●", "String" }, { " Active", "Normal" } }
  }
}, 60)
```

---

### `ui.tabs(data, w, opts)`

Create tabbed interface.

**Parameters:**
- `data` (string[]): Array of tab names (use `"_pad_"` for dynamic spacing)
- `w` (number): Total width
- `opts` (TabOptions)

**TabOptions:**
```lua
{
  active = string,         -- Currently active tab name
  hlon = string,           -- Active highlight (optional, default: "normal")
  hloff = string           -- Inactive highlight (optional, default: "commentfg")
}
```

**Returns:** `table[]` - Three lines (top border, text, bottom border)

**Example:**
```lua
local tabs = ui.tabs(
  { "Home", "_pad_", "Settings", "About" },
  60,
  { active = "Settings", hlon = "Title" }
)
```

---

### `ui.graphs.bar(data)`

Create a bar graph.

**Parameters:**
- `data` (BarGraphData)

**BarGraphData:**
```lua
{
  val = number[],          -- Data values (0-10 scale)
  baropts = {
    w = number,            -- Bar width
    gap = number,          -- Gap between bars
    icon = string,         -- Bar character (optional, default: "█")
    hl = string,           -- Single color OR
    dual_hl = string[],    -- [inactive, active] colors OR
    format_hl = function(val) -> string  -- Dynamic highlight
  },
  format_labels = function(val) -> string,  -- Y-axis labels (optional)
  footer_label = table     -- Footer virtual text (optional)
}
```

**Returns:** `table[]` - Array of graph lines

**Example:**
```lua
local graphs = require("volt.ui.graphs")

local bar = graphs.bar({
  val = { 5, 8, 3, 10, 7 },
  baropts = {
    w = 3,
    gap = 1,
    icon = "█",
    format_hl = function(val)
      if val >= 80 then return "Error" end
      return "String"
    end
  },
  format_labels = function(val)
    return tostring(val) .. "%"
  end,
  footer_label = { "Week", "Comment" }
})
```

---

### `ui.graphs.dot(data)`

Create a dot graph.

**Parameters:**
- `data` (DotGraphData)

**DotGraphData:**
```lua
{
  val = number[],          -- Data values (0-10 scale)
  baropts = {
    icons = {
      on = string,         -- Active icon (default: " 󰄰")
      off = string         -- Inactive icon (default: " ·")
    },
    hl = {
      on = string,         -- Active hl (default: "exblue")
      off = string         -- Inactive hl (default: "commentfg")
    },
    sidelabels = boolean,  -- Show Y-axis (default: true)
    format_icon = function(val) -> string,  -- Dynamic icon (optional)
    format_hl = function(val) -> string     -- Dynamic hl (optional)
  },
  format_labels = function(val) -> string,  -- Y-axis labels (optional)
  footer_label = table     -- Footer virtual text (optional)
}
```

**Returns:** `table[]` - Array of graph lines

**Example:**
```lua
local dot = graphs.dot({
  val = { 5, 8, 3, 10, 7 },
  baropts = {
    icons = { on = " 󰄰", off = " ·" },
    hl = { on = "String", off = "Comment" },
    sidelabels = true
  }
})
```

---

### `ui.grid_col(columns)`

Arrange components in columns.

**Parameters:**
- `columns` (ColumnConfig[])

**ColumnConfig:**
```lua
{
  lines = table[],         -- Line data
  w = number,              -- Column width
  pad = number             -- Right padding (optional, default: 0)
}
```

**Returns:** `table[]` - Combined grid lines

**Example:**
```lua
local grid = ui.grid_col({
  { lines = col1_lines, w = 30, pad = 2 },
  { lines = col2_lines, w = 30, pad = 0 }
})
```

---

### `ui.grid_row(parts)`

Concatenate line groups horizontally.

**Parameters:**
- `parts` (table[][]): Array of line groups

**Returns:** `table` - Combined line

**Example:**
```lua
local row = ui.grid_row({
  { { "Left", "Normal" } },
  { { " | ", "Comment" } },
  { { "Right", "String" } }
})
```

---

### `ui.border(lines, hl?)`

Add border around content. **Modifies `lines` in-place.**

**Parameters:**
- `lines` (table[]): Line array to wrap
- `hl` (string|nil): Border highlight (default: "linenr")

**Example:**
```lua
local lines = {
  { { "Content 1", "Normal" } },
  { { "Content 2", "Normal" } }
}

ui.border(lines, "Comment")

-- Now lines includes border:
-- ┌──────────┐
-- │ Content 1│
-- │ Content 2│
-- └──────────┘
```

---

### `ui.hpad(line, w)`

Fill horizontal padding to reach width.

**Parameters:**
- `line` (table): Line with `"_pad_"` markers
- `w` (number): Total desired width

**Returns:** `table` - Line with padding filled

**Example:**
```lua
local line = {
  { "Left", "Normal" },
  { "_pad_" },
  { "Right", "Normal" }
}

ui.hpad(line, 50)
-- Padding is calculated and filled
```

---

### `ui.line_w(line)`

Calculate total width of virtual text line.

**Parameters:**
- `line` (table): Virtual text line

**Returns:** `number` - Total width

**Example:**
```lua
local width = ui.line_w({
  { "Hello", "Normal" },
  { " ", "Normal" },
  { "World", "String" }
})
-- Returns: 11
```

---

## Event System

### `volt.events` Module

Handles user interactions.

```lua
local events = require("volt.events")
```

---

#### `events.enable()`

Enable global event system. **Call once** in your configuration.

Sets up `vim.on_key()` handlers for mouse events.

**Example:**
```lua
require("volt.events").enable()
```

---

#### `events.add(buffers)`

Register buffer(s) for event handling.

**Parameters:**
- `buffers` (number|number[]): Buffer ID or array of IDs

**Example:**
```lua
events.add(buf)
events.add({ buf1, buf2, buf3 })
```

---

#### `events.bufs`

Array of currently registered buffer IDs.

**Type:** `number[]`

---

### Virtual Text Actions

Define interactive regions in virtual text.

#### Click-Only Action

```lua
{
  "Click me",
  "HighlightGroup",
  function()
    -- Click handler
  end
}
```

#### Click and Hover Actions

```lua
{
  "Hover me",
  "Normal",
  {
    ui_type = "slider",    -- Optional: "slider" for special handling
    click = function()
      -- Click handler
    end,
    hover = {
      id = "unique_id",           -- Hover state identifier
      callback = function()       -- Hover callback (optional)
        vim.g.nvmark_hovered = "unique_id"
      end,
      redraw = string[]           -- Sections to redraw on hover
    }
  }
}
```

#### Check Hover State

```lua
if vim.g.nvmark_hovered == "unique_id" then
  -- Element is being hovered
end
```

---

## Color Utilities

### `volt.color` Module

Color manipulation and conversion utilities.

```lua
local color = require("volt.color")
```

---

#### `color.hex2rgb(hex)`

Convert hex color to RGB.

**Parameters:**
- `hex` (string): Hex color (with or without #)

**Returns:** `number, number, number` - R, G, B (0-255)

**Example:**
```lua
local r, g, b = color.hex2rgb("#ff5555")
-- r=255, g=85, b=85
```

---

#### `color.hex2rgb_ratio(hex)`

Convert hex to RGB ratios.

**Parameters:**
- `hex` (string): Hex color

**Returns:** `number, number, number` - R, G, B (0-100)

---

#### `color.rgb2hex(r, g, b)`

Convert RGB to hex color.

**Parameters:**
- `r` (number): Red (0-255)
- `g` (number): Green (0-255)
- `b` (number): Blue (0-255)

**Returns:** `string` - Hex color

**Example:**
```lua
local hex = color.rgb2hex(255, 85, 85)
-- hex="#ff5555"
```

---

#### `color.hex2hsl(hex)`

Convert hex to HSL.

**Parameters:**
- `hex` (string): Hex color

**Returns:** `number, number, number` - H (0-360), S (0-1), L (0-1)

---

#### `color.hsl2hex(h, s, l)`

Convert HSL to hex.

**Parameters:**
- `h` (number): Hue (0-360)
- `s` (number): Saturation (0-1)
- `l` (number): Lightness (0-1)

**Returns:** `string` - Hex color

---

#### `color.rgb2hsl(r, g, b)`

Convert RGB to HSL.

**Parameters:**
- `r` (number): Red (0-255)
- `g` (number): Green (0-255)
- `b` (number): Blue (0-255)

**Returns:** `number, number, number` - H (0-360), S (0-1), L (0-1)

---

#### `color.hsl2rgb(h, s, l)`

Convert HSL to RGB.

**Parameters:**
- `h` (number): Hue (0-360)
- `s` (number): Saturation (0-1)
- `l` (number): Lightness (0-1)

**Returns:** `number, number, number` - R, G, B (0-255)

---

#### `color.change_hex_lightness(hex, percent)`

Lighten or darken a color.

**Parameters:**
- `hex` (string): Hex color
- `percent` (number): Amount to change (-100 to 100)
  - Positive: lighter
  - Negative: darker

**Returns:** `string` - Modified hex color

**Example:**
```lua
local lighter = color.change_hex_lightness("#ff5555", 20)
local darker = color.change_hex_lightness("#ff5555", -20)
```

---

#### `color.change_hex_saturation(hex, percent)`

Adjust color saturation.

**Parameters:**
- `hex` (string): Hex color
- `percent` (number): Amount to change (-100 to 100)

**Returns:** `string` - Modified hex color

---

#### `color.change_hex_hue(hex, percent)`

Shift color hue.

**Parameters:**
- `hex` (string): Hex color
- `percent` (number): Hue shift as percentage of 360°

**Returns:** `string` - Modified hex color

**Example:**
```lua
local shifted = color.change_hex_hue("#ff5555", 50)
```

---

#### `color.mix(first, second, strength)`

Mix two colors.

**Parameters:**
- `first` (string): Primary hex color
- `second` (string): Color to mix in
- `strength` (number): Amount of second color (0-100)

**Returns:** `string` - Mixed hex color

**Example:**
```lua
local mixed = color.mix("#ff5555", "#5555ff", 50)
-- 50/50 mix of red and blue
```

---

#### `color.compute_gradient(hex1, hex2, steps)`

Generate color gradient.

**Parameters:**
- `hex1` (string): Start color
- `hex2` (string): End color
- `steps` (number): Number of steps

**Returns:** `string[]` - Array of hex colors

**Example:**
```lua
local gradient = color.compute_gradient("#ff5555", "#5555ff", 10)
-- Returns 10 colors from red to blue
```

---

#### `color.hex2complementary(hex, count)`

Generate complementary colors.

**Parameters:**
- `hex` (string): Base color
- `count` (number): Number of complementary colors

**Returns:** `string[]` - Array of hex colors

**Example:**
```lua
local complements = color.hex2complementary("#ff5555", 3)
```

---

## State Management

### `volt.state` Module

Buffer-specific state storage.

```lua
local state = require("volt.state")
```

### State Structure

```lua
state[buf] = {
  clickables = table,      -- Click regions per row
  hoverables = table,      -- Hover regions per row
  layout = table,          -- Layout definition
  ns = number,             -- Namespace ID
  xpad = number,           -- Horizontal padding
  h = number,              -- Total height
  buf = number,            -- Buffer ID
  hovered_extmarks = any   -- Currently hovered sections
}
```

### Click/Hover Region Structure

```lua
state[buf].clickables[row_number] = {
  {
    col_start = number,
    col_end = number,
    ui_type = string,      -- Optional: "slider"
    actions = function|table,
    hover = table          -- Hover config (optional)
  },
  -- ... more regions in this row
}
```

---

## Utilities

### `volt.utils` Module

Helper utilities.

```lua
local utils = require("volt.utils")
```

---

#### `utils.cycle_bufs(bufs)`

Cycle through array of buffers.

**Parameters:**
- `bufs` (number[]): Array of buffer IDs

---

#### `utils.cycle_clickables(buf, step)`

Navigate through clickable elements.

**Parameters:**
- `buf` (number): Buffer ID
- `step` (number): Direction (1 or -1)

---

#### `utils.close(config)`

Close UI and cleanup.

**Parameters:**
- `config` (CloseConfig)

**CloseConfig:**
```lua
{
  bufs = number[],                 -- Buffers to close
  close_func = function(buf),      -- Per-buffer cleanup (optional)
  after_close = function()         -- Final cleanup (optional)
}
```

**Example:**
```lua
utils.close({
  bufs = { buf1, buf2 },
  close_func = function(buf)
    print("Closing", buf)
  end,
  after_close = function()
    print("All closed")
  end
})
```

---

#### `utils.get_hl(name)`

Get highlight group colors.

**Parameters:**
- `name` (string): Highlight group name

**Returns:** `table` - `{ fg = "#rrggbb", bg = "#rrggbb" }`

**Example:**
```lua
local hl = utils.get_hl("Normal")
-- { fg = "#ffffff", bg = "#000000" }
```

---

## Type Definitions

### Layout Definition

```lua
---@class VoltSection
---@field name string Section identifier
---@field row? number Starting row (auto-calculated)
---@field col_start? number Column offset
---@field lines fun(buf: number): table[] Function returning line data

---@class VoltLayout
---@field [number] VoltSection
```

### Line Data

```lua
---@class VoltVirtualText
---@field [1] string Text content
---@field [2] string Highlight group
---@field [3]? function|table Click handler or action config

---@class VoltLine
---@field [number] VoltVirtualText
```

### Action Config

```lua
---@class VoltAction
---@field ui_type? string Special UI type ("slider")
---@field click? function Click handler
---@field hover? VoltHover Hover configuration

---@class VoltHover
---@field id string Unique identifier
---@field callback? function Hover callback
---@field redraw string[] Sections to redraw
```

### Component Options

```lua
---@class CheckboxOptions
---@field active boolean Current state
---@field txt string Label text
---@field check? string Checked icon
---@field uncheck? string Unchecked icon
---@field hlon? string Active highlight
---@field hloff? string Inactive highlight
---@field actions? function Click handler

---@class SliderOptions
---@field txt? string Label text
---@field val number Current value (0-100)
---@field w number Width
---@field hlon string Active highlight
---@field hloff? string Inactive highlight
---@field thumb? boolean Show thumb
---@field thumb_icon? string Thumb icon
---@field ratio_txt? boolean Show percentage
---@field actions function Value change handler

---@class ProgressOptions
---@field w number Width
---@field val number Progress (0-100)
---@field icon? table Icon config
---@field hl? table Highlight config
```

---

## Highlight Groups

Volt automatically creates these highlight groups:

| Group | Description |
|-------|-------------|
| `ExDarkBg` | Darkest background |
| `ExDarkBorder` | Dark border |
| `ExBlack2Bg` | Medium background |
| `ExBlack2Border` | Medium border |
| `ExBlack3Bg` | Light background |
| `ExBlack3Border` | Light border |
| `ExRed` | Red foreground |
| `ExYellow` | Yellow foreground |
| `ExBlue` | Blue foreground |
| `ExGreen` | Green foreground |
| `ExLightGrey` | Light grey foreground |
| `CommentFg` | Comment-like foreground |

These adapt to:
- NvChad's base46 theme system
- Your current colorscheme
- Light/dark background setting

---

## Internal Modules

These modules are used internally but can be accessed if needed:

### `volt.draw`

```lua
local draw = require("volt.draw")
draw(buf, section)  -- Draw a single section
```

### `volt.highlights`

```lua
require("volt.highlights")  -- Loads highlight definitions
```

---

This API reference covers all public interfaces in Volt. For implementation details, see the [Developer Guide](DEVELOPER_GUIDE.md).
