-- Treesitter (needs the `tree-sitter` CLI installed)
require("nvim-treesitter").install({
    "go", "rust", "typescript", "javascript", "tsx",
    "html", "css", "json", "bash", "http", "dockerfile",
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    callback = function(args)
        local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
        if not lang then return end
        if not pcall(vim.treesitter.language.add, lang) then return end
        pcall(vim.treesitter.start, args.buf, lang)
    end,
})
