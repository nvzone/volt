# Volt User Guide

Welcome to Volt! This guide will teach you how to use Volt to create beautiful interactive UIs in Neovim.

## Table of Contents

- [Getting Started](#getting-started)
- [Basic Concepts](#basic-concepts)
- [UI Components](#ui-components)
- [Layouts](#layouts)
- [Event Handling](#event-handling)
- [Styling](#styling)
- [Examples](#examples)

## Getting Started

### Installation

Install Volt using your preferred plugin manager:

**lazy.nvim:**
```lua
{
  "NvChad/volt",
  lazy = true,
}
```

**packer.nvim:**
```lua
use {
  "NvChad/volt",
  opt = true,
}
```

**vim.pack**
```lua
vim.pack.add({
  { src = "https://github.com/nvzone/volt" },
})
```

### Your First Volt UI

```lua
local volt = require("volt")

-- Create a buffer
local buf = vim.api.nvim_create_buf(false, true)
vim.bo[buf].bufhidden = "wipe"

-- Define layout
local layout = {
  {
    name = "greeting",
    lines = function()
      return {
        { { "Hello, Volt! ⚡", "Title" } }
      }
    end
  }
}

-- Setup UI data
volt.gen_data({
  {
    buf = buf,
    layout = layout,
    ns = vim.api.nvim_create_namespace("my_ui"),
    xpad = 2,
  }
})

-- Create window
local win = vim.api.nvim_open_win(buf, true, {
  relative = "editor",
  width = 40,
  height = 5,
  row = 10,
  col = 10,
  style = "minimal",
  border = "rounded",
})

-- Render
volt.run(buf, { h = 5, w = 40 })
```

## Basic Concepts

### Virtual Text Structure

Volt uses Neovim's virtual text (extmarks) to render UI. Each line is an array of "cells":

```lua
{
  { "text", "highlight_group" },
  { " more text", "another_highlight" },
  { " clickable", "special_hl", callback_function }
}
```

Structure:
1. **Text**: The string to display
2. **Highlight**: Highlight group name
3. **Action** (optional): Function to execute on click

### Layout Sections

Your UI is divided into named sections:

```lua
local layout = {
  {
    name = "header",      -- Section identifier
    row = 0,              -- Starting row (auto-calculated)
    col_start = 5,        -- Optional: column offset
    lines = function(buf) -- Function returning line data
      return {
        { { "Header Text", "Title" } }
      }
    end
  },
  {
    name = "content",
    lines = function(buf)
      return {
        { { "Content line 1", "Normal" } },
        { { "Content line 2", "Normal" } }
      }
    end
  }
}
```

### State Management

Volt maintains state per buffer:

```lua
local state = require("volt.state")

-- Access buffer state
local buf_state = state[buf]

-- State contains:
-- buf_state.clickables  - Click regions per row
-- buf_state.hoverables  - Hover regions per row
-- buf_state.layout      - Your layout definition
-- buf_state.ns          - Namespace ID
-- buf_state.xpad        - Horizontal padding
```

## UI Components

### Checkbox

Create toggleable checkboxes:

```lua
local ui = require("volt.ui")

local checked = false

local checkbox = ui.checkbox({
  active = checked,
  txt = "Enable dark mode",
  check = "✓",      -- Custom check icon (default: )
  uncheck = "✗",    -- Custom uncheck icon (default: )
  hlon = "String",  -- Active highlight
  hloff = "Comment", -- Inactive highlight
  actions = function()
    checked = not checked
    volt.redraw(buf, "section_name")
  end
})

-- Use in your layout
lines = function()
  return { checkbox }
end
```

### Slider

Interactive value sliders:

```lua
local volume = 50

local slider_line = ui.slider.config({
  txt = "Volume: ",     -- Label text
  val = volume,         -- Current value (0-100)
  w = 40,              -- Width
  hlon = "String",     -- Active color
  hloff = "Comment",   -- Inactive color
  thumb = true,        -- Show thumb indicator
  thumb_icon = "",   -- Custom thumb icon
  ratio_txt = true,    -- Show percentage
  actions = function()
    -- Get new value based on cursor position
    volume = ui.slider.val(40, "Volume: ", 2)
    volt.redraw(buf, "section_name")
  end
})
```

**Keyboard Navigation**: Move cursor over slider and press Enter to update value.

### Progress Bar

Show progress indicators:

```lua
local progress = ui.progressbar({
  w = 30,              -- Width
  val = 65,            -- Progress (0-100)
  icon = {
    on = "━",          -- Active icon
    off = "─"          -- Inactive icon
  },
  hl = {
    on = "String",     -- Active highlight
    off = "Comment"    -- Inactive highlight
  }
})

-- Returns: { { active_part, hl }, { inactive_part, hl } }
```

### Separator

Horizontal dividers:

```lua
local separator = ui.separator("─", 50, "Comment")
-- Character, width, highlight
```

### Tabs

Create tabbed interfaces:

```lua
local active_tab = "Settings"

local tabs = ui.tabs(
  { "Home", "Settings", "About" },  -- Tab names
  60,                                -- Total width
  {
    active = active_tab,             -- Currently active
    hlon = "Title",                  -- Active highlight
    hloff = "Comment"                -- Inactive highlight
  }
)

-- Returns 3 lines: top border, text, bottom border
```

### Table

Create formatted tables:

```lua
local data = {
  { "Name", "Age", "City" },      -- Header row
  { "Alice", "25", "New York" },
  { "Bob", "30", "Los Angeles" },
  { "Carol", "28", "Chicago" }
}

local table_lines = ui.table(
  data,
  60,              -- Total width
  "Title",         -- Header highlight
  { "Users", "Title" }  -- Optional title
)
```

Tables support complex cells with virtual text:

```lua
local complex_data = {
  { "Name", "Status" },
  { 
    "Alice", 
    { { "●", "String" }, { " Active", "Normal" } }  -- Virtual text cell
  }
}
```

### Graphs

#### Bar Graph

```lua
local graphs = require("volt.ui.graphs")

local bar_data = graphs.bar({
  val = { 5, 8, 3, 10, 7, 6 },  -- Data points (0-10 scale)
  baropts = {
    w = 3,              -- Bar width
    gap = 1,            -- Gap between bars
    icon = "█",         -- Bar character
    hl = "String",      -- Single color, or:
    dual_hl = { "Comment", "String" },  -- [inactive, active]
    -- OR
    format_hl = function(val)
      if val >= 80 then return "Error" end
      if val >= 50 then return "Warning" end
      return "String"
    end
  },
  format_labels = function(val)
    return tostring(val) .. "%"
  end,
  footer_label = { "Performance", "Title" }
})
```

#### Dot Graph

```lua
local dot_data = graphs.dot({
  val = { 5, 8, 3, 10, 7 },
  baropts = {
    icons = {
      on = " 󰄰",       -- Active icon
      off = " ·"        -- Inactive icon
    },
    hl = {
      on = "String",
      off = "Comment"
    },
    sidelabels = true,  -- Show Y-axis labels
    format_icon = function(val)
      if val >= 80 then return " " end
      return " 󰄰"
    end
  },
  footer_label = { "Metrics", "Title" }
})
```

## Layouts

### Grid Column Layout

Arrange content in columns:

```lua
local grid_col = require("volt.ui.grid_col")

local column1 = {
  lines = { { { "Col 1 Line 1", "Normal" } } },
  w = 20,
  pad = 2  -- Right padding
}

local column2 = {
  lines = { { { "Col 2 Line 1", "Normal" } } },
  w = 20,
  pad = 0
}

local grid_lines = grid_col({ column1, column2 })
```

### Grid Row Layout

Concatenate multiple line groups:

```lua
local ui = require("volt.ui")

local row = ui.grid_row({
  { { "Part 1", "Normal" } },
  { { " | ", "Comment" } },
  { { "Part 2", "String" } }
})
-- Combines all parts into single line
```

### Borders

Add borders around content:

```lua
local lines = {
  { { "Content line 1", "Normal" } },
  { { "Content line 2", "Normal" } }
}

ui.border(lines, "Comment")  -- Adds border with given highlight

-- Before:
-- Content line 1
-- Content line 2

-- After:
-- ┌──────────────────┐
-- │ Content line 1   │
-- │ Content line 2   │
-- └──────────────────┘
```

### Horizontal Padding

Add dynamic padding:

```lua
local line = {
  { "Left text", "Normal" },
  { "_pad_" },  -- Will be replaced with spaces
  { "Right text", "Normal" }
}

ui.hpad(line, 50)  -- Total width
-- Calculates and fills padding automatically
```

Calculate line width:

```lua
local width = ui.line_w(line)
```

## Event Handling

### Enable Events

```lua
-- Enable global event system (call once)
require("volt.events").enable()

-- Register buffer(s)
require("volt.events").add(buf)

-- Register multiple buffers
require("volt.events").add({ buf1, buf2, buf3 })
```

### Click Events

```lua
{
  "Click me!",
  "String",
  function()
    print("Clicked!")
    volt.redraw(buf, "my_section")
  end
}
```

### Hover Events

```lua
{
  "Hover me!",
  "Normal",
  {
    click = function()
      print("Clicked!")
    end,
    hover = {
      id = "hover_state_1",
      callback = function()
        vim.g.nvmark_hovered = "hover_state_1"
      end,
      redraw = { "section_to_update" }
    }
  }
}
```

Check hover state:

```lua
if vim.g.nvmark_hovered == "hover_state_1" then
  -- Element is being hovered
end
```

### Slider Interaction

Sliders have special UI type:

```lua
{
  text = "━━━━━━",
  hl = "String",
  {
    ui_type = "slider",
    click = function()
      local new_val = ui.slider.val(width, label, xpad, { thumb = true })
      -- Update value
    end
  }
}
```

## Styling

### Highlight Groups

Volt provides these highlight groups:

```lua
-- Dark backgrounds
ExDarkBg
ExDarkBorder

-- Medium backgrounds
ExBlack2Bg
ExBlack2Border

-- Light backgrounds
ExBlack3Bg
ExBlack3Border

-- Colors
ExRed
ExYellow
ExBlue
ExGreen
ExLightGrey
CommentFg
```

These automatically adapt to:
- Your colorscheme
- NvChad's base46 theme system
- Light/dark background

### Custom Highlights

Override or create your own:

```lua
vim.api.nvim_set_hl(0, "MyCustomHL", {
  fg = "#ff5555",
  bg = "#282a36",
  bold = true
})
```

## Examples

### Complete Modal Dialog

```lua
local volt = require("volt")
local ui = require("volt.ui")

local function create_dialog()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"
  
  local confirmed = false
  
  local layout = {
    {
      name = "title",
      lines = function()
        return {
          { { "⚠ Confirmation Required", "Title" } }
        }
      end
    },
    {
      name = "separator",
      lines = function()
        return { ui.separator("─", 50, "Comment") }
      end
    },
    {
      name = "message",
      lines = function()
        return {
          { { "Are you sure you want to continue?", "Normal" } }
        }
      end
    },
    {
      name = "buttons",
      lines = function()
        return {
          ui.grid_row({
            { { "  ", "Normal" } },
            { 
              { " ✓ Confirm ", "String" },
              {
                click = function()
                  confirmed = true
                  volt.close(buf)
                end
              }
            },
            { { "  ", "Normal" } },
            { 
              { " ✗ Cancel ", "Error" },
              {
                click = function()
                  volt.close(buf)
                end
              }
            }
          })
        }
      end
    }
  }
  
  volt.gen_data({{
    buf = buf,
    layout = layout,
    ns = vim.api.nvim_create_namespace("dialog"),
    xpad = 2
  }})
  
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = 50,
    height = 8,
    row = math.floor(vim.o.lines / 2) - 4,
    col = math.floor(vim.o.columns / 2) - 25,
    style = "minimal",
    border = "rounded"
  })
  
  volt.run(buf, { h = 8, w = 50 })
  require("volt.events").add(buf)
  
  return confirmed
end
```

### Settings Panel

```lua
local function create_settings()
  local buf = vim.api.nvim_create_buf(false, true)
  
  local settings = {
    dark_mode = true,
    auto_save = false,
    font_size = 14
  }
  
  local layout = {
    {
      name = "header",
      lines = function()
        return { { { "⚙ Settings", "Title" } } }
      end
    },
    {
      name = "separator1",
      lines = function()
        return { ui.separator("─", 60, "Comment") }
      end
    },
    {
      name = "dark_mode",
      lines = function()
        return {
          ui.checkbox({
            active = settings.dark_mode,
            txt = "Dark mode",
            actions = function()
              settings.dark_mode = not settings.dark_mode
              volt.redraw(buf, "dark_mode")
            end
          })
        }
      end
    },
    {
      name = "auto_save",
      lines = function()
        return {
          ui.checkbox({
            active = settings.auto_save,
            txt = "Auto-save",
            actions = function()
              settings.auto_save = not settings.auto_save
              volt.redraw(buf, "auto_save")
            end
          })
        }
      end
    },
    {
      name = "font_size",
      lines = function()
        return {
          ui.slider.config({
            txt = "Font size: ",
            val = math.floor((settings.font_size - 8) / 24 * 100),
            w = 45,
            hlon = "String",
            thumb = true,
            ratio_txt = false,
            actions = function()
              local percent = ui.slider.val(45, "Font size: ", 2, { thumb = true })
              settings.font_size = math.floor(8 + (percent / 100) * 24)
              volt.redraw(buf, "font_size")
            end
          })
        }
      end
    }
  }
  
  volt.gen_data({{
    buf = buf,
    layout = layout,
    ns = vim.api.nvim_create_namespace("settings"),
    xpad = 2
  }})
  
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = 60,
    height = 12,
    row = 5,
    col = 10,
    style = "minimal",
    border = "rounded"
  })
  
  volt.run(buf, { h = 12, w = 60 })
  require("volt.events").add(buf)
end
```

### Statistics Dashboard

```lua
local function create_dashboard()
  local buf = vim.api.nvim_create_buf(false, true)
  local graphs = require("volt.ui.graphs")
  
  local data = { 7, 8, 6, 9, 10, 8, 9 }
  
  local layout = {
    {
      name = "title",
      lines = function()
        return { { { "📊 Weekly Statistics", "Title" } } }
      end
    },
    {
      name = "separator",
      lines = function()
        return { ui.separator("─", 70, "Comment") }
      end
    },
    {
      name = "graph",
      lines = function()
        return graphs.bar({
          val = data,
          baropts = {
            w = 4,
            gap = 2,
            icon = "█",
            format_hl = function(val)
              if val >= 80 then return "String" end
              if val >= 50 then return "Function" end
              return "Comment"
            end
          },
          format_labels = function(val)
            return tostring(val * 10)
          end,
          footer_label = { "Day of Week", "Comment" }
        })
      end
    },
    {
      name = "stats",
      lines = function()
        local avg = 0
        for _, v in ipairs(data) do avg = avg + v end
        avg = math.floor(avg / #data * 10)
        
        return {
          { { "", "Normal" } },
          { { "Average: " .. avg .. "%", "Comment" } },
          { { "Peak: " .. math.max(unpack(data)) * 10 .. "%", "Comment" } }
        }
      end
    }
  }
  
  volt.gen_data({{
    buf = buf,
    layout = layout,
    ns = vim.api.nvim_create_namespace("dashboard"),
    xpad = 5
  }})
  
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = 70,
    height = 20,
    row = 2,
    col = 10,
    style = "minimal",
    border = "rounded"
  })
  
  volt.run(buf, { h = 20, w = 70 })
  require("volt.events").add(buf)
end
```

## Tips & Best Practices

1. **Always enable events**: Call `require("volt.events").enable()` once in your config
2. **Register buffers**: Use `require("volt.events").add(buf)` for interactive elements
3. **Use sections**: Name your layout sections for easy redraws
4. **Leverage closures**: Capture state in your `lines` functions
5. **Clean up**: Volt handles buffer deletion, but you can add custom cleanup
6. **Test interactivity**: Ensure click targets are appropriately sized
7. **Consider themes**: Use Volt's highlight groups for theme compatibility

## Troubleshooting

**Clicks not working?**
- Ensure `require("volt.events").enable()` was called
- Verify buffer is registered with `require("volt.events").add(buf)`
- Check if mouse is enabled: `:set mouse=a`

**UI not rendering?**
- Confirm buffer is valid and window is visible
- Check if `volt.run(buf, opts)` was called
- Verify layout functions return proper format

**Colors look wrong?**
- Load highlights: Volt automatically loads them, but ensure your colorscheme is set first
- Use `:so $VIMRUNTIME/syntax/hitest.vim` to see available highlights

## Next Steps

- Read the [Developer Guide](DEVELOPER_GUIDE.md) for advanced topics
- Check out the [source code](https://github.com/NvChad/volt) of Minty, Menu, and Typr
- Join the [NvChad Discord](https://discord.gg/gADmkJb9Fb) for help
