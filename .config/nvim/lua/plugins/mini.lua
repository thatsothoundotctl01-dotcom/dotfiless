-- All mini.nvim modules

---- mini.files ----
local MiniFiles = require("mini.files")
MiniFiles.setup({
    mappings = {
        go_in = "<CR>",
        go_in_plus = "L",
        go_out = "_",
        go_out_plus = "H",
    },
})
vim.keymap.set("n", "-", function() MiniFiles.open() end, { desc = "Toggle mini file explorer" })
vim.keymap.set("n", "<leader>-", function()
    MiniFiles.open(vim.api.nvim_buf_get_name(0), false)
    MiniFiles.reveal_cwd()
end, { desc = "Open explorer at current file" })

---- mini.notify ----
require("mini.notify").setup({
    content = { format = function(notif) return notif.msg end },
})

---- mini.cmdline ----
require("mini.cmdline").setup({ autocorrect = { enable = false } })

---- mini.pairs (auto-close brackets and quotes) ----
require("mini.pairs").setup()

-- Enter between {} () [] opens an indented block
vim.keymap.set("i", "<CR>", function()
    if vim.fn.pumvisible() == 1 then
        return vim.fn.complete_info({ "selected" }).selected ~= -1 and "<C-y>" or "<CR>"
    end
    local col = vim.fn.col(".") - 1
    local line = vim.api.nvim_get_current_line()
    local pair = line:sub(col, col) .. line:sub(col + 1, col + 1)
    if pair == "{}" or pair == "()" or pair == "[]" then
        return "<CR><Esc>O"
    end
    return "<CR>"
end, { expr = true, desc = "Smart Enter between brackets" })

---- mini.surround ----
-- sa add | sd delete | sr replace | sf/sF find | sh highlight | sn n_lines
require("mini.surround").setup()

---- mini.pick / mini.extra ----
local MiniPick = require("mini.pick")
local MiniExtra = require("mini.extra")
MiniPick.setup()
MiniExtra.setup()

vim.keymap.set("n", "<leader>pf", function() MiniPick.builtin.files() end, { desc = "Mini file picker" })
vim.keymap.set("n", "<leader>ps", function()
    MiniPick.builtin.grep({ pattern = vim.fn.expand("<cword>") })
end, { desc = "Grep word under cursor" })
vim.keymap.set("n", "<leader>vh", function() MiniPick.builtin.help() end, { desc = "Mini help" })
vim.keymap.set("n", "<leader>xx", function() MiniExtra.pickers.diagnostic() end, { desc = "Diagnostics picker" })
vim.keymap.set("n", "<leader>pk", function() MiniExtra.pickers.keymaps() end, { desc = "Search keymaps" })

---- mini.completion ----
require("mini.completion").setup({ lsp_completion = { auto_setup = true } })

---- mini.snippets ----
local MiniSnippets = require("mini.snippets")
MiniSnippets.setup({
    snippets = { MiniSnippets.gen_loader.from_lang() }, -- loads friendly-snippets
})
MiniSnippets.start_lsp_server({ match = false })
