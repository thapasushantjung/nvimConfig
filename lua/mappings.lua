require "nvchad.mappings"

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- Hop.nvim keymaps
local hop = require "hop"
local directions = require("hop.hint").HintDirection

map("", "sf", function()
  hop.hint_char2()
end, { remap = true })

map("", "L", function()
  vim.cmd ":HopLineStart"
end, { remap = true })
