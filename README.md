# ⚡ Volt

**Create blazing fast & beautiful reactive UIs in Neovim**

Volt is a powerful framework for building interactive, clickable, and hoverable user interfaces directly within Neovim using virtual text and extmarks. Built by [siduck](https://github.com/siduck) for the [NvChad](https://nvchad.com) ecosystem.

![License](https://img.shields.io/badge/license-GPL--3.0-blue.svg)
![Neovim](https://img.shields.io/badge/Neovim-0.9+-green.svg)

## 📑 Table of Contents

- [Features](#-features)
- [Showcase](#-showcase)
- [Installation](#-installation)
- [Quick Start](#-quick-start)
- [Documentation](#-documentation)
- [Core Components](#-core-components)
- [Color Utilities](#-color-utilities)
- [Building Your UI](#-building-your-ui)
- [Advanced Features](#-advanced-features)
- [Key Mappings](#-key-mappings)
- [Contributing](#-contributing)
- [License](#-license)
- [Credits](#-credits)
- [Support](#-support)

## ✨ Features

- **🎨 Rich UI Components**: Sliders, checkboxes, tables, tabs, progress bars, and graphs
- **🖱️ Interactive Elements**: Full mouse and keyboard support for clickable/hoverable UI
- **⚡ Blazing Fast**: Leverages Neovim's native virtual text (extmarks) for rendering
- **🎯 Event-Driven**: Simple callback-based system for handling user interactions
- **📊 Data Visualization**: Built-in bar and dot graph components
- **🎨 Themeable**: Automatically adapts to your Neovim colorscheme
- **🔧 Modular**: Composable components for building complex UIs

## 📸 Showcase

### Plugins Built with Volt

#### [Minty](https://github.com/NvChad/minty) - Color Tools
Beautiful color picker, shade generator, and huefy tools.

![Minty Shades](https://github.com/user-attachments/assets/d499748b-d9c8-4a92-89ba-bfce1814c275)
![Minty Huefy](https://github.com/user-attachments/assets/21f2c23d-94c6-4ccf-a0d0-ddf91f6bb5c1)

#### [Menu](https://github.com/NvChad/menu) - Menu Creator
Extensible menu and submenu system.

![Menu](https://github.com/user-attachments/assets/c8402279-b86d-432f-ad11-14a76c887ab1)

#### [Typr](https://github.com/NvChad/typr) - Typing Practice
Beautiful typing practice with stats dashboard.

![Typr](https://github.com/user-attachments/assets/4426d1c4-c4d3-4da7-987a-3b4c4395a4b5)
![Typr Stats](https://github.com/user-attachments/assets/b1653de3-05f3-4b90-b35e-9341eed8bf3e)

#### [Base46 Theme Picker](https://github.com/NvChad/base46)
Interactive theme picker with multiple styles.

![Theme Picker](https://github.com/user-attachments/assets/897e46f1-9ae2-4cc2-8fa2-64eff40a90dd)

## 📦 Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "NvChad/volt",
  lazy = true,
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "NvChad/volt",
  opt = true,
}
```

### Using Neovim's built-in `vim.pack`

```lua
vim.pack.add({
  { src = "https://github.com/NvChad/volt" },
})
```

## 🚀 Quick Start

Here's a minimal example to create a simple interactive UI:

```lua
local volt = require("volt")

-- Create a buffer for your UI
local buf = vim.api.nvim_create_buf(false, true)

-- Define your UI layout
local layout = {
  {
    name = "header",
    lines = function()
      return {
        { { "Hello from Volt! ⚡", "Title" } }
      }
    end
  }
}

-- Generate the UI data
volt.gen_data({
  {
    buf = buf,
    layout = layout,
    ns = vim.api.nvim_create_namespace("my_volt_ui"),
    xpad = 2, -- horizontal padding
  }
})

-- Create a window and show the UI
local win = vim.api.nvim_open_win(buf, true, {
  relative = "editor",
  width = 60,
  height = 10,
  row = 5,
  col = 5,
  style = "minimal",
  border = "rounded",
})

-- Render the UI
volt.run(buf, { h = 10, w = 60 })
```

## 📚 Documentation

- **[User Guide](docs/USER_GUIDE.md)**: Learn how to use Volt components
- **[Developer Guide](docs/DEVELOPER_GUIDE.md)**: Build your own UI with Volt
- **[API Reference](docs/API.md)**: Complete API documentation
- **`:help volt`**: Vim help documentation (after installation)

## 🧩 Core Components

Volt provides a rich set of UI components out of the box:

### Basic Components
- **Checkbox**: Toggle states with custom icons
- **Slider**: Interactive value selector with mouse/keyboard support
- **Progress Bar**: Visual progress indicators
- **Separator**: Horizontal dividers
- **Tabs**: Tabbed interface navigation

### Layout Components
- **Grid Column**: Multi-column layouts
- **Grid Row**: Row-based layouts
- **Border**: Add borders around content
- **Horizontal Padding**: Dynamic padding system

### Data Visualization
- **Bar Graph**: Vertical bar charts with customization
- **Dot Graph**: Scatter-style data visualization
- **Table**: Formatted tables with borders and alignment

### Utilities
- **Color Utilities**: HSL/RGB/HEX conversions, color mixing, gradients
- **Event System**: Mouse and keyboard event handling
- **State Management**: Buffer-specific state tracking

## 🎨 Color Utilities

Volt includes comprehensive color manipulation functions:

```lua
local color = require("volt.color")

-- Convert between formats
local r, g, b = color.hex2rgb("#ff5555")
local hex = color.rgb2hex(255, 85, 85)
local h, s, l = color.hex2hsl("#ff5555")

-- Modify colors
local lighter = color.change_hex_lightness("#ff5555", 20)  -- lighten by 20%
local saturated = color.change_hex_saturation("#ff5555", -30)  -- desaturate
local shifted = color.change_hex_hue("#ff5555", 45)  -- shift hue

-- Mix colors
local mixed = color.mix("#ff5555", "#5555ff", 50)  -- 50/50 mix

-- Generate gradients
local gradient = color.compute_gradient("#ff5555", "#5555ff", 10)

-- Complementary colors
local complements = color.hex2complementary("#ff5555", 3)
```

## 🛠️ Building Your UI

### 1. Define Your Layout

```lua
local layout = {
  {
    name = "section1",
    lines = function(buf)
      return {
        { 
          { "Text", "Highlight" },
          { " More text", "Normal" },
          { 
            " Clickable",
            "Special",
            function() print("Clicked!") end  -- Click handler
          }
        }
      }
    end
  }
}
```

### 2. Create Interactive Elements

```lua
local ui = require("volt.ui")

-- Slider
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

-- Checkbox
local checkbox = ui.checkbox({
  active = true,
  txt = "Enable feature",
  check = "✓",
  uncheck = "✗",
  hlon = "String",
  hloff = "Comment",
  actions = function()
    -- Toggle logic
  end
})

-- Table
local table_lines = ui.table({
  { "Name", "Age", "City" },
  { "Alice", "25", "NYC" },
  { "Bob", "30", "LA" }
}, 60, "Title")
```

### 3. Enable Events

```lua
-- Enable mouse and keyboard events
require("volt.events").enable()

-- Register your buffer(s)
require("volt.events").add(buf)
```

## 🔧 Advanced Features

### Hover Effects

```lua
{
  "Hoverable text",
  "Normal",
  {
    click = function() print("Clicked") end,
    hover = {
      id = "my_hover",
      redraw = { "section_to_redraw" },
      callback = function()
        vim.g.nvmark_hovered = "my_hover"
      end
    }
  }
}
```

### Dynamic Redraws

```lua
-- Redraw specific sections
volt.redraw(buf, "section_name")

-- Redraw multiple sections
volt.redraw(buf, { "section1", "section2" })

-- Redraw everything
volt.redraw(buf, "all")
```

### Graphs

```lua
local graphs = require("volt.ui.graphs")

-- Bar graph
local bar_graph = graphs.bar({
  val = { 5, 8, 3, 10, 7 },
  baropts = {
    w = 3,
    gap = 1,
    icon = "█",
    hl = "String",
    dual_hl = { "Comment", "String" },  -- inactive/active colors
  },
  format_labels = function(val)
    return tostring(val) .. "%"
  end,
  footer_label = { "Performance", "Title" }
})

-- Dot graph
local dot_graph = graphs.dot({
  val = { 5, 8, 3, 10, 7 },
  baropts = {
    icons = { on = " 󰄰", off = " ·" },
    hl = { on = "String", off = "Comment" },
    sidelabels = true,
  }
})
```

## 🎯 Key Mappings

When using Volt UIs, the following keys are automatically mapped:

- **`<CR>`**: Activate the element under cursor
- **`<Tab>`**: Cycle to next clickable element
- **`<S-Tab>`**: Cycle to previous clickable element
- **`q` / `<Esc>`**: Close the UI
- **`<C-t>`**: Cycle between multiple buffers (if configured)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

## 🙏 Credits

- **Creator**: [Siduck](https://github.com/siduck)
- **Color utilities**: Based on work by [Leon Heidelbach](https://github.com/LeonHeidelbach)
- **Part of**: [NvChad](https://nvchad.com) ecosystem

## 🔗 Related Projects

- [NvChad](https://github.com/NvChad/NvChad) - Blazing fast Neovim framework
- [Minty](https://github.com/NvChad/minty) - Color tools built with Volt
- [Menu](https://github.com/NvChad/menu) - Menu system built with Volt
- [Typr](https://github.com/NvChad/typr) - Typing practice built with Volt

## 📞 Support

- 🐛 [Report Bugs](https://github.com/NvChad/volt/issues)
- 💡 [Feature Requests](https://github.com/NvChad/volt/issues)
- 💬 [Discord](https://discord.gg/gADmkJb9Fb) - Join the NvChad community
- 📖 [Documentation](https://nvchad.com)

---

<div align="center">

**[⭐ Star this repository](https://github.com/NvChad/volt) if you find it useful!**

Made with ⚡ by the NvChad team

</div>
