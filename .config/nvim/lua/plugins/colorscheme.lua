-- Colorscheme: moonfly, with italics removed everywhere
vim.g.moonflyItalics = false

local function strip_italics()
    for name, hl in pairs(vim.api.nvim_get_hl(0, {})) do
        if hl.italic then
            hl.italic = false
            vim.api.nvim_set_hl(0, name, hl)
        end
    end
end
vim.api.nvim_create_autocmd("ColorScheme", { callback = strip_italics })

vim.cmd.colorscheme("moonfly")
strip_italics()
