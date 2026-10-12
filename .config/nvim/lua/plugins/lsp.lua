-- LSP + Mason + diagnostics
require("mason").setup()

vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, { desc = "Format buffer" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show line diagnostics" })

-- Error-lens style: inline message at end of line, live while typing
vim.diagnostic.config({
    virtual_text = { spacing = 2, prefix = "●", source = "if_many" },
    underline = true,
    signs = true,
    update_in_insert = true,
    severity_sort = true,
    float = { border = "rounded", source = true },
})

local capabilities = vim.tbl_deep_extend(
    "force",
    vim.lsp.protocol.make_client_capabilities(),
    require("mini.completion").get_lsp_capabilities()
)
vim.lsp.config("*", { capabilities = capabilities })

vim.lsp.config("lua_ls", {
    settings = { Lua = { diagnostics = { globals = { "vim" } } } },
})

-- Add more servers here
vim.lsp.enable({ "lua_ls", "marksman", "gopls", "rust_analyzer" })
