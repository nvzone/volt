-- lua/volt/icons/full.lua
-- Extracted subset of the full nvim-web-devicons dataset.
-- Only a representative subset is included here to keep file short.
-- The extraction script (scripts/extract_icons.lua) can be used to generate
-- a complete table from an installed nvim-web-devicons.

return {
  by_extension = {
    lua = { icon = "", color = "#51A0CF", name = "Lua" },
    js  = { icon = "", color = "#EAD41C", name = "JavaScript" },
    ts  = { icon = "", color = "#2b7489", name = "TypeScript" },
    py  = { icon = "", color = "#3572A5", name = "Python" },
    rs  = { icon = "", color = "#dea584", name = "Rust" },
    go  = { icon = "", color = "#00ADD8", name = "Go" },
    md  = { icon = "", color = "#083fa1", name = "Markdown" },
    json= { icon = "ﬥ", color = "#cbcb41", name = "JSON" },
    sh  = { icon = "", color = "#6e4a7e", name = "Shell" },
    toml= { icon = "", color = "#9c4221", name = "TOML" },
    -- Note: full dataset would continue here...
  },
  by_filename = {
    [".gitignore"] = { icon = "", color = "#F54D27", name = "GitIgnore" },
    ["Makefile"]   = { icon = "", color = "#6D8086", name = "Makefile" },
    ["Dockerfile"] = { icon = "", color = "#0db7ed", name = "Dockerfile" },
    ["README.md"]  = { icon = "", color = "#083fa1", name = "Readme" },
    ["LICENSE"]    = { icon = "", color = "#6d8086", name = "License" },
    ["package.json"]= { icon = "", color = "#cbcb41", name = "Npm" },
    ["tsconfig.json"]= { icon = "", color = "#2b7489", name = "TSConfig" },
    ["Cargo.toml"] = { icon = "", color = "#dea584", name = "Cargo" },
    [".env"]       = { icon = "", color = "#4f5d95", name = "Env" },
    ["init.lua"]   = { icon = "", color = "#51A0CF", name = "LuaInit" },
    -- Note: full dataset would continue here...
  },
}
