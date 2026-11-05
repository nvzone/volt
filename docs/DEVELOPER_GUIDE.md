# Volt Developer Guide

This guide is for developers who want to build plugins and applications using the Volt framework.

## Table of Contents

- [Architecture Overview](#architecture-overview)
- [Core Modules](#core-modules)
- [Building a Plugin](#building-a-plugin)
- [Advanced Patterns](#advanced-patterns)
- [Performance Optimization](#performance-optimization)
- [Testing](#testing)

## Architecture Overview

### How Volt Works

Volt leverages Neovim's **extmarks** (extended marks) and **virtual text** to render UIs directly in buffers without modifying actual buffer content. Here's the rendering pipeline:

```
Layout Definition → gen_data() → State Creation → draw() → Extmarks → Visual UI
                                       ↓
                                Event System ← User Interaction
```

### Key Principles

1. **Declarative UI**: Define what to render, not how to render it
2. **Reactive Updates**: Update specific sections without full redraws
3. **Event-Driven**: Mouse and keyboard events trigger callbacks
4. **State Per Buffer**: Each buffer has isolated state
5. **Virtual Text**: No buffer modification, pure visual overlay

## Core Modules

### `volt.init` - Main Entry Point

```lua
local volt = require("volt")

-- Generate state and calculate layout
volt.gen_data(config)

-- Render UI to buffer
volt.run(buf, options)

-- Redraw specific sections
volt.redraw(buf, section_name)

-- Setup empty lines for rendering
volt.set_empty_lines(buf, height, width)

-- Add keymaps to buffers
volt.mappings(config)

-- Toggle UI visibility
volt.toggle_func(open_function, state_variable)

-- Close UI
volt.close(buf)
```

### `volt.state` - State Management

The state module maintains buffer-specific data:

```lua
local state = require("volt.state")

-- State structure for each buffer
state[buf] = {
  clickables = {},   -- Click regions indexed by row
  hoverables = {},   -- Hover regions indexed by row
  layout = {},       -- Layout definition
  ns = namespace_id, -- Namespace for extmarks
  xpad = 0,          -- Horizontal padding
  h = 0,             -- Total height
  buf = buf,         -- Buffer ID
  hovered_extmarks = nil -- Currently hovered sections
}
```

### `volt.draw` - Rendering Engine

The draw module converts layout data to extmarks:

```lua
local draw = require("volt.draw")

-- Internal use - draws a section
draw(buf, section)
```

**Process:**
1. Calculates virtual text positions
2. Registers clickable/hoverable regions
3. Creates extmarks with `nvim_buf_set_extmark`

### `volt.events` - Event System

Handles user interactions:

```lua
local events = require("volt.events")

-- Enable global event system
events.enable()

-- Register buffer(s)
events.add(buf)
events.add({ buf1, buf2, buf3 })

-- Internally tracked buffers
events.bufs -- Array of registered buffers
```

**Event Flow:**
```
User Input → vim.on_key() → MouseMove/LeftMouse → 
  → Get Position → Find Virtual Element → 
  → Execute Callback → Redraw if needed
```

### `volt.highlights` - Theme System

Automatically creates highlight groups:

```lua
-- Highlights are created automatically
-- They adapt to base46 (NvChad) or your colorscheme

-- Available groups:
ExDarkBg, ExDarkBorder       -- Darkest
ExBlack2Bg, ExBlack2Border   -- Medium
ExBlack3Bg, ExBlack3Border   -- Lighter
ExRed, ExYellow, ExBlue, ExGreen
ExLightGrey, CommentFg
```

### `volt.color` - Color Utilities

Comprehensive color manipulation:

```lua
local color = require("volt.color")

-- Conversions
color.hex2rgb(hex)           → r, g, b
color.rgb2hex(r, g, b)       → hex
color.hex2hsl(hex)           → h, s, l
color.hsl2hex(h, s, l)       → hex
color.hex2rgb_ratio(hex)     → r%, g%, b%

-- Transformations
color.change_hex_hue(hex, percent)
color.change_hex_saturation(hex, percent)
color.change_hex_lightness(hex, percent)

-- Generation
color.compute_gradient(hex1, hex2, steps)
color.hex2complementary(hex, count)
color.mix(first, second, strength)
```

### `volt.utils` - Helper Functions

```lua
local utils = require("volt.utils")

-- Cycle through buffers
utils.cycle_bufs(buffer_array)

-- Cycle clickable elements
utils.cycle_clickables(buf, step) -- step: 1 or -1

-- Close UI and cleanup
utils.close({
  bufs = { buf1, buf2 },
  close_func = function(buf) end,
  after_close = function() end
})

-- Get highlight table
local hl = utils.get_hl("Normal")
-- Returns: { fg = "#rrggbb", bg = "#rrggbb" }
```

## Building a Plugin

### Step 1: Plugin Structure

```lua
-- lua/myplugin/init.lua
local M = {}
local volt = require("volt")
local ui = require("volt.ui")

-- Plugin state
local state = {
  is_open = false,
  buf = nil,
  win = nil,
  data = {}
}

-- Your plugin logic
M.setup = function(opts)
  -- Configuration
end

M.toggle = function()
  volt.toggle_func(M.open, state.is_open)
  state.is_open = not state.is_open
end

M.open = function()
  -- Create UI
end

M.close = function()
  volt.close(state.buf)
  state.is_open = false
end

return M
```

### Step 2: Create Buffer and Window

```lua
M.open = function()
  -- Create buffer
  state.buf = vim.api.nvim_create_buf(false, true)
  vim.bo[state.buf].bufhidden = "wipe"
  vim.bo[state.buf].filetype = "MyPlugin"
  
  -- Calculate dimensions
  local width = 80
  local height = 30
  
  -- Create window
  state.win = vim.api.nvim_open_win(state.buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
    title = " My Plugin ",
    title_pos = "center"
  })
  
  -- Window options
  vim.wo[state.win].cursorline = false
  vim.wo[state.win].wrap = false
  
  -- Setup UI
  setup_ui()
end
```

### Step 3: Define Layout

```lua
local function setup_ui()
  local layout = {
    {
      name = "header",
      lines = function(buf)
        return {
          { { "My Amazing Plugin", "Title" } },
          { { "", "Normal" } }
        }
      end
    },
    {
      name = "controls",
      lines = function(buf)
        return create_controls()
      end
    },
    {
      name = "content",
      lines = function(buf)
        return create_content()
      end
    },
    {
      name = "footer",
      lines = function(buf)
        return {
          { { "", "Normal" } },
          ui.separator("─", 76, "Comment"),
          { 
            { " q: quit ", "Comment" },
            { " <Tab>: next ", "Comment" }
          }
        }
      end
    }
  }
  
  -- Generate data
  volt.gen_data({
    {
      buf = state.buf,
      layout = layout,
      ns = vim.api.nvim_create_namespace("myplugin"),
      xpad = 2
    }
  })
  
  -- Render
  volt.run(state.buf, { 
    h = 30, 
    w = 80,
    winclosed_event = true  -- Auto-close on window close
  })
  
  -- Enable events
  if not vim.g.extmarks_events then
    require("volt.events").enable()
  end
  require("volt.events").add(state.buf)
  
  -- Add custom mappings
  volt.mappings({
    bufs = { state.buf },
    winclosed_event = true
  })
end
```

### Step 4: Implement Interactive Elements

```lua
local function create_controls()
  local lines = {}
  
  -- Slider example
  table.insert(lines, 
    ui.slider.config({
      txt = "Volume: ",
      val = state.data.volume or 50,
      w = 60,
      hlon = "String",
      hloff = "Comment",
      thumb = true,
      ratio_txt = true,
      actions = function()
        state.data.volume = ui.slider.val(60, "Volume: ", 2, { thumb = true })
        volt.redraw(state.buf, "controls")
        -- Do something with new volume
        update_volume(state.data.volume)
      end
    })
  )
  
  -- Checkbox example
  table.insert(lines,
    ui.checkbox({
      active = state.data.enabled or false,
      txt = "Enable feature",
      actions = function()
        state.data.enabled = not state.data.enabled
        volt.redraw(state.buf, { "controls", "content" })
        -- React to change
        on_feature_toggle(state.data.enabled)
      end
    })
  )
  
  return lines
end
```

### Step 5: Dynamic Content

```lua
local function create_content()
  if not state.data.enabled then
    return {
      { { "Feature is disabled", "Comment" } }
    }
  end
  
  -- Generate dynamic content based on state
  local lines = {}
  
  for i, item in ipairs(state.data.items or {}) do
    table.insert(lines, {
      { tostring(i) .. ". ", "LineNr" },
      { item.name, "Normal" },
      { 
        "  [×]",
        "Error",
        function()
          table.remove(state.data.items, i)
          volt.redraw(state.buf, "content")
        end
      }
    })
  end
  
  -- Add button
  table.insert(lines, { { "", "Normal" } })
  table.insert(lines, {
    { 
      " + Add Item ",
      "String",
      function()
        table.insert(state.data.items, { name = "New Item" })
        volt.redraw(state.buf, "content")
      end
    }
  })
  
  return lines
end
```

## Advanced Patterns

### Multi-Buffer UIs

Create tabbed interfaces with multiple buffers:

```lua
local buffers = {}
local current_tab = "main"

local function create_tab(name)
  local buf = vim.api.nvim_create_buf(false, true)
  buffers[name] = buf
  
  -- Setup layout for this buffer
  local layout = get_layout_for_tab(name)
  
  volt.gen_data({
    {
      buf = buf,
      layout = layout,
      ns = vim.api.nvim_create_namespace("tab_" .. name),
      xpad = 2
    }
  })
  
  return buf
end

local function switch_tab(name)
  current_tab = name
  local buf = buffers[name]
  vim.api.nvim_win_set_buf(state.win, buf)
  volt.redraw(buf, "all")
end

-- Setup with volt.mappings for Ctrl+T cycling
volt.mappings({
  bufs = vim.tbl_values(buffers),
  winclosed_event = true
})
```

### Hover Effects

Implement visual feedback on hover:

```lua
local function create_hover_button(text, action)
  return {
    text,
    vim.g.nvmark_hovered == "btn_" .. text and "Title" or "Normal",
    {
      click = action,
      hover = {
        id = "btn_" .. text,
        callback = function()
          vim.g.nvmark_hovered = "btn_" .. text
        end,
        redraw = { "section_name" }
      }
    }
  }
end
```

### Async Operations

Handle async data loading:

```lua
local function load_data_async()
  -- Show loading state
  state.loading = true
  volt.redraw(state.buf, "content")
  
  vim.defer_fn(function()
    -- Fetch data (could be from file, API, etc.)
    state.data = fetch_data()
    state.loading = false
    
    -- Update UI
    volt.redraw(state.buf, "content")
  end, 100)
end

local function create_content()
  if state.loading then
    return {
      { { "Loading...", "Comment" } }
    }
  end
  
  -- Render actual content
  return render_data(state.data)
end
```

### Custom Input Handling

Create custom input fields:

```lua
local function create_input()
  local input_value = state.input or ""
  
  return {
    { "Input: ", "Comment" },
    { 
      input_value .. "█",  -- Cursor
      "Normal",
      {
        click = function()
          vim.ui.input({ prompt = "Enter value: ", default = input_value }, 
            function(value)
              if value then
                state.input = value
                volt.redraw(state.buf, "input_section")
                on_input_change(value)
              end
            end
          )
        end
      }
    }
  }
end
```

### Keyboard Shortcuts

Add custom key handlers:

```lua
vim.api.nvim_buf_set_keymap(state.buf, "n", "a", "", {
  callback = function()
    -- Your action
    add_item()
    volt.redraw(state.buf, "list")
  end,
  noremap = true,
  silent = true
})

vim.api.nvim_buf_set_keymap(state.buf, "n", "d", "", {
  callback = function()
    delete_selected()
    volt.redraw(state.buf, "list")
  end,
  noremap = true,
  silent = true
})
```

### Stateful Animations

Create simple animations:

```lua
local animation_state = { frame = 1, timer = nil }

local function start_animation()
  animation_state.timer = vim.loop.new_timer()
  animation_state.timer:start(0, 100, vim.schedule_wrap(function()
    animation_state.frame = (animation_state.frame % 8) + 1
    volt.redraw(state.buf, "spinner")
  end))
end

local function stop_animation()
  if animation_state.timer then
    animation_state.timer:stop()
    animation_state.timer = nil
  end
end

local function create_spinner()
  local frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧" }
  return {
    { frames[animation_state.frame] .. " Loading", "Comment" }
  }
end
```

## Performance Optimization

### Minimize Redraws

Only redraw what changes:

```lua
-- Bad: Redraw everything
volt.redraw(buf, "all")

-- Good: Redraw specific sections
volt.redraw(buf, { "header", "content" })

-- Best: Redraw only changed section
volt.redraw(buf, "changed_section")
```

### Lazy Rendering

Generate content only when visible:

```lua
local function create_large_list()
  -- Only render visible portion
  local start_idx = state.scroll_pos
  local end_idx = math.min(start_idx + 20, #state.items)
  
  local lines = {}
  for i = start_idx, end_idx do
    table.insert(lines, render_item(state.items[i]))
  end
  
  return lines
end
```

### Memoization

Cache expensive computations:

```lua
local cache = {}

local function get_computed_data(key)
  if not cache[key] then
    cache[key] = expensive_computation(key)
  end
  return cache[key]
end

-- Invalidate when needed
local function invalidate_cache(key)
  cache[key] = nil
end
```

### Batch Updates

Group state changes:

```lua
-- Bad: Multiple redraws
for _, item in ipairs(items) do
  process_item(item)
  volt.redraw(buf, "list")
end

-- Good: Single redraw
for _, item in ipairs(items) do
  process_item(item)
end
volt.redraw(buf, "list")
```

## Testing

### Unit Testing Example

```lua
-- tests/myplug_spec.lua
describe("MyPlugin", function()
  local plugin
  
  before_each(function()
    plugin = require("myplugin")
    plugin.setup()
  end)
  
  it("creates buffer on open", function()
    plugin.open()
    assert.is_not_nil(plugin.state.buf)
    assert.is_true(vim.api.nvim_buf_is_valid(plugin.state.buf))
  end)
  
  it("handles toggle correctly", function()
    assert.is_false(plugin.state.is_open)
    plugin.toggle()
    assert.is_true(plugin.state.is_open)
    plugin.toggle()
    assert.is_false(plugin.state.is_open)
  end)
  
  it("cleans up on close", function()
    plugin.open()
    local buf = plugin.state.buf
    plugin.close()
    assert.is_false(vim.api.nvim_buf_is_valid(buf))
  end)
end)
```

### Integration Testing

```lua
-- Manual testing helper
M.debug = function()
  print("State:", vim.inspect(state))
  print("Buffer:", state.buf)
  print("Layout sections:", #state.layout)
  
  local volt_state = require("volt.state")[state.buf]
  print("Clickables:", vim.inspect(volt_state.clickables))
  print("Hoverables:", vim.inspect(volt_state.hoverables))
end
```

## Best Practices

### Code Organization

```
lua/myplugin/
├── init.lua          -- Main entry point
├── config.lua        -- Configuration
├── state.lua         -- State management
├── ui/
│   ├── layout.lua    -- Layout definitions
│   ├── components.lua -- Custom components
│   └── theme.lua     -- Theming
└── utils.lua         -- Utilities
```

### Error Handling

```lua
local function safe_action(fn)
  return function(...)
    local ok, err = pcall(fn, ...)
    if not ok then
      vim.notify(
        "MyPlugin error: " .. tostring(err),
        vim.log.levels.ERROR
      )
    end
  end
end

-- Use in actions
{
  "Click me",
  "Normal",
  safe_action(function()
    -- Potentially failing code
  end)
}
```

### User Configuration

```lua
local default_config = {
  width = 80,
  height = 30,
  theme = "auto",
  keymaps = {
    toggle = "<leader>mp",
    close = "q"
  }
}

M.setup = function(opts)
  local config = vim.tbl_deep_extend("force", default_config, opts or {})
  
  -- Setup keymap
  vim.keymap.set("n", config.keymaps.toggle, M.toggle, {
    desc = "Toggle MyPlugin"
  })
  
  return config
end
```

### Documentation

Add vim.doc comments:

```lua
--- Open the plugin UI
--- @param opts table|nil Optional configuration
--- @field width number Window width (default: 80)
--- @field height number Window height (default: 30)
M.open = function(opts)
  -- Implementation
end
```

## Real-World Examples

Study these plugins built with Volt:

1. **[Minty](https://github.com/NvChad/minty)**: Color tools with sliders and pickers
2. **[Menu](https://github.com/NvChad/menu)**: Nested menu system
3. **[Typr](https://github.com/NvChad/typr)**: Typing practice with statistics
4. **[Base46 Theme Picker](https://github.com/NvChad/base46)**: Theme selection UI

## Getting Help

- **Discord**: [NvChad Community](https://discord.gg/gADmkJb9Fb)
- **Issues**: [GitHub Issues](https://github.com/NvChad/volt/issues)
- **Discussions**: Share your Volt plugins!

## Contributing to Volt

Interested in improving Volt itself? Check out:

- Follow the existing code style (see `.stylua.toml`)
- Add tests for new features
- Update documentation
- Submit PRs to the [main repo](https://github.com/NvChad/volt)

---

Happy building with Volt! ⚡
