-- Git: mini.diff (signs in the gutter) + fugitive
local MiniDiff = require("mini.diff")
MiniDiff.setup({ source = MiniDiff.gen_source.git({ index = false }) })

vim.keymap.set("n", "<leader>gg", "<cmd>tabnew | Git | only<cr>", { desc = "Fugitive full page in new tab" })
vim.keymap.set("n", "<leader>gd", "<cmd>Gvdiffsplit<CR>", { desc = "Git diff split" })
