-- ~/.config/nvim/init.lua
-- Developer-focused single-file config for Neovim 0.12+
-- Goal: write code fast. Leader = <Space>. Press <Space> and wait for key hints.

local ok_ui2, ui2 = pcall(require, "vim._core.ui2")
if ok_ui2 then ui2.enable({}) end

------------------------------------------------------------
-- Options
------------------------------------------------------------
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.netrw_banner = 0

local o = vim.opt
o.termguicolors = true
o.mouse = "a"
o.nu = true
o.relativenumber = true
o.cursorline = true
o.signcolumn = "yes"
o.scrolloff = 8
o.colorcolumn = "0"
o.wrap = false
o.winborder = "rounded"
o.splitkeep = "screen"
o.fillchars:append({ eob = " " }) -- hide the ~ on empty lines

-- Indent
o.tabstop = 4
o.softtabstop = 4
o.shiftwidth = 4
o.expandtab = true
o.smartindent = true

-- Search
o.ignorecase = true
o.smartcase = true
o.inccommand = "split"

-- Windows
o.splitbelow = true
o.splitright = true
o.laststatus = 3 -- normal built-in statusline (one bar at the bottom)

-- Files / undo
o.swapfile = false
o.backup = false
o.undodir = vim.fn.stdpath("data") .. "/undodir"
o.undofile = true
o.autoread = true
o.confirm = true -- ask instead of failing on :q with changes

-- Speed
o.updatetime = 250
o.timeoutlen = 300 -- also makes `jj` snappy

-- Completion
o.completeopt = "menuone,noselect,fuzzy,nosort"
o.pumheight = 12
o.shortmess:append("c")

o.clipboard:append("unnamedplus")
o.isfname:append("@-@")

-- LazyVim style mode-aware cursor shape & blinking
o.guicursor =
"n-v-c-sm:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175"

------------------------------------------------------------
-- Autocommands (small quality-of-life things)
------------------------------------------------------------
local augroup = vim.api.nvim_create_augroup("dev_config", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
    group = augroup,
    desc = "Highlight when yanking (copying) text",
    callback = function() vim.hl.on_yank() end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
    group = augroup,
    desc = "Restore last cursor position",
    callback = function(args)
        local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
        local lines = vim.api.nvim_buf_line_count(args.buf)
        if mark[1] > 0 and mark[1] <= lines then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
    group = augroup,
    desc = "Create missing parent directories on save",
    callback = function(args)
        if args.match:match("^%w%w+:[\\/][\\/]") then return end
        vim.fn.mkdir(vim.fn.fnamemodify(args.file, ":p:h"), "p")
    end,
})

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
    group = augroup,
    desc = "Reload files changed outside nvim",
    command = "silent! checktime",
})

vim.api.nvim_create_autocmd("VimResized", {
    group = augroup,
    desc = "Keep splits equal on terminal resize",
    command = "wincmd =",
})

------------------------------------------------------------
-- Keymaps
------------------------------------------------------------
local map = vim.keymap.set

-- Editing
map("x", "p", [["_dP]], { desc = "Paste over selection without losing yanked text" })
map({ "n", "v" }, "<leader>d", [["_d]], { desc = "Delete without yanking" })
map("i", "<C-c>", "<Esc>")
map("i", "jj", "<Esc>", { desc = "Exit insert mode" })
map("n", "<C-c>", ":nohl<CR>", { desc = "Clear search highlighting", silent = true })

map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move lines down in visual selection" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move lines up in visual selection" })
map("v", "<", "<gv", { desc = "Unindent and keep selection" })
map("v", ">", ">gv", { desc = "Indent and keep selection" })
map("n", "J", "mzJ`z", { desc = "Join lines without moving cursor" })

-- Navigation
map("n", "<C-d>", "<C-d>zz", { desc = "Move down with cursor centered" })
map("n", "<C-u>", "<C-u>zz", { desc = "Move up with cursor centered" })
map("n", "n", "nzzzv", { desc = "Next search result centered" })
map("n", "N", "Nzzzv", { desc = "Previous search result centered" })

-- Windows and buffers
map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<leader>w", "<cmd>write<cr>", { desc = "Save file" })
map("n", "<leader>q", "<cmd>quit<cr>", { desc = "Quit window" })
map("n", "<leader>Q", "<cmd>qa<cr>", { desc = "Quit all" })

-- Misc
map("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
    { desc = "Replace word under cursor globally" })
map("n", "<leader>X", "<cmd>!chmod +x %<CR>", { silent = true, desc = "Make file executable" })
map("n", "<leader>re", "<cmd>restart<cr>", { desc = "Restart Neovim" })

-- Terminal
map("n", "<leader>tt", "<cmd>botright 12split | terminal<cr>i", { desc = "Open terminal at bottom" })
map("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Leave terminal mode" })

-- native undotree
map("n", "<leader>u", function()
    vim.cmd.packadd("nvim.undotree")
    require("undotree").open()
end, { desc = "Toggle builtin undotree" })

-- Smart completion keys: Tab / Shift-Tab pick, Enter accepts
map("i", "<Tab>", function() return vim.fn.pumvisible() == 1 and "<C-n>" or "<Tab>" end,
    { expr = true, desc = "Next completion / Tab" })
map("i", "<S-Tab>", function() return vim.fn.pumvisible() == 1 and "<C-p>" or "<S-Tab>" end,
    { expr = true, desc = "Previous completion" })

-- Enter: accept selected completion, or open an indented block between {} () []
map("i", "<CR>", function()
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
end, { expr = true, desc = "Smart Enter" })

------------------------------------------------------------
-- Commands
------------------------------------------------------------
vim.api.nvim_create_user_command("PackAdd", function(opts)
    vim.pack.add(opts.fargs)
end, { nargs = "+", desc = "Add plugins (:PackAdd user/repo1 user/repo2)" })

vim.api.nvim_create_user_command("PackDel", function(opts)
    vim.pack.del(opts.fargs)
end, { nargs = "+", desc = "Delete plugins (:PackDel plugin1 plugin2)" })

vim.api.nvim_create_user_command("PackUpdate", function(opts)
    if opts.args:match("%S") then
        vim.pack.update(vim.split(opts.args, "%s+", { trimempty = true }))
    else
        vim.pack.update()
    end
end, { nargs = "*", desc = "Update all plugins or specific ones" })

------------------------------------------------------------
-- Plugins
------------------------------------------------------------
vim.pack.add({
    "https://github.com/nvim-mini/mini.nvim",
    "https://github.com/rafamadriz/friendly-snippets",
    { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
    "https://github.com/neovim/nvim-lspconfig",
    "https://github.com/mason-org/mason.nvim",
    "https://github.com/tpope/vim-fugitive",
    "https://github.com/CRAG666/code_runner.nvim",
})


---- code_runner (F6 = run current file, F7 = close output) ----
require("code_runner").setup({
    mode = "term",
    focus = true,
    startinsert = false,
    term = { position = "bot", size = 12 },
    filetype = {
        python     = "cd $dir && python3 -u $fileName",
        javascript = "cd $dir && node $fileName",
        typescript = "cd $dir && npx tsx $fileName",
        lua        = "cd $dir && nvim -l $fileName",
        sh         = "cd $dir && bash $fileName",
        bash       = "cd $dir && bash $fileName",
        php        = "cd $dir && php $fileName",
        ruby       = "cd $dir && ruby $fileName",
        perl       = "cd $dir && perl $fileName",
        go         = "cd $dir && go run $fileName",
        rust       = "cd $dir && rustc $fileName -o /tmp/$fileNameWithoutExt && /tmp/$fileNameWithoutExt",
        c          = "cd $dir && gcc $fileName -o /tmp/$fileNameWithoutExt && /tmp/$fileNameWithoutExt",
        cpp        = "cd $dir && g++ $fileName -o /tmp/$fileNameWithoutExt && /tmp/$fileNameWithoutExt",
        java       = "cd $dir && javac $fileName && java $fileNameWithoutExt",
        zig        = "cd $dir && zig run $fileName",
    },
})

map("n", "<F6>", function()
    if vim.api.nvim_buf_get_name(0) == "" then
        vim.notify("Save the file first", vim.log.levels.WARN)
        return
    end
    if vim.bo.modified then vim.cmd("silent write") end
    require("code_runner").run_code()
end, { desc = "Run current file" })
map("n", "<F7>", "<cmd>RunClose<cr>", { desc = "Close code runner window" })

---- mini.icons (file icons everywhere) ----
local MiniIcons = require("mini.icons")
MiniIcons.setup()
MiniIcons.mock_nvim_web_devicons()

---- mini.files (file explorer) ----
local MiniFiles = require("mini.files")
MiniFiles.setup({
    mappings = {
        go_in = "<CR>",
        go_in_plus = "L",
        go_out = "_",
        go_out_plus = "H",
    },
})
map("n", "-", function() MiniFiles.open() end, { desc = "Toggle mini file explorer" })
map("n", "<leader>-", function()
    MiniFiles.open(vim.api.nvim_buf_get_name(0), false)
    MiniFiles.reveal_cwd()
end, { desc = "Open explorer at current file" })

-- F5 to open project/file folder view using mini.files
map("n", "<F5>", function()
    local current_file = vim.api.nvim_buf_get_name(0)
    if current_file == "" then
        MiniFiles.open(vim.uv.cwd(), false)
    else
        MiniFiles.open(current_file, false)
        MiniFiles.reveal_cwd()
    end
end, { desc = "Open project folder view" })

---- mini.pairs (auto-close braces, brackets, quotes) ----
require("mini.pairs").setup()

---- mini.comment (gcc = toggle line, gc{motion}, gc in visual) ----
require("mini.comment").setup()

---- mini.surround (sa add, sd delete, sr replace) ----
require("mini.surround").setup()

---- mini.ai (better text objects: af/if call, aa/ia argument, aq quote, ab bracket) ----
require("mini.ai").setup()

---- mini.move (Alt+h/j/k/l moves line or selection) ----
require("mini.move").setup()

---- mini.splitjoin (gS toggles one-line <-> multi-line args/tables) ----
require("mini.splitjoin").setup()

---- mini.bracketed ([b ]b buffers, [d ]d diagnostics, [q ]q quickfix ...) ----
require("mini.bracketed").setup()

---- mini.bufremove (close buffer without closing the window) ----
local MiniBufremove = require("mini.bufremove")
MiniBufremove.setup()
map("n", "<leader>bd", function() MiniBufremove.delete() end, { desc = "Delete buffer" })

---- mini.trailspace (trim trailing whitespace on save; no pink highlight) ----
require("mini.trailspace").setup()
local function hide_trailspace_hl()
    vim.api.nvim_set_hl(0, "MiniTrailspace", { bg = "NONE", fg = "NONE" })
end
hide_trailspace_hl()
vim.api.nvim_create_autocmd("ColorScheme", { callback = hide_trailspace_hl })
vim.api.nvim_create_autocmd("BufWritePre", {
    group = augroup,
    callback = function()
        if vim.bo.buftype == "" then
            MiniTrailspace.trim()
            MiniTrailspace.trim_last_lines()
        end
    end,
})

---- mini.indentscope / mini.cursorword ----
require("mini.indentscope").setup({ symbol = "│", options = { try_as_border = true } })
require("mini.cursorword").setup()

---- mini.hipatterns (highlight TODO/FIXME/NOTE and #hex colors) ----
local hipatterns = require("mini.hipatterns")
hipatterns.setup({
    highlighters = {
        fixme     = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
        hack      = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
        todo      = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
        note      = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },
        hex_color = hipatterns.gen_highlighter.hex_color(),
    },
})

---- mini.tabline (open buffers on top) ----
require("mini.tabline").setup()

---- mini.notify / mini.cmdline ----
require("mini.notify").setup({
    content = { format = function(notif) return notif.msg end },
})
require("mini.cmdline").setup({ autocorrect = { enable = false } })

---- mini.pick / mini.extra (fuzzy finders) ----
local MiniPick = require("mini.pick")
local MiniExtra = require("mini.extra")
MiniPick.setup()
MiniExtra.setup()
vim.ui.select = MiniPick.ui_select -- code actions etc. use the picker

map("n", "<leader><space>", function() MiniPick.builtin.buffers() end, { desc = "Buffers" })
map("n", "<leader>pf", function() MiniPick.builtin.files() end, { desc = "Find files" })
map("n", "<leader>pg", function() MiniPick.builtin.grep_live() end, { desc = "Live grep (ripgrep)" })
map("n", "<leader>ps", function()
    MiniPick.builtin.grep({ pattern = vim.fn.expand("<cword>") })
end, { desc = "Grep word under cursor" })
map("n", "<leader>pr", function() MiniExtra.pickers.oldfiles() end, { desc = "Recent files" })
map("n", "<leader>pk", function() MiniExtra.pickers.keymaps() end, { desc = "Search keymaps" })
map("n", "<leader>vh", function() MiniPick.builtin.help() end, { desc = "Help pages" })
map("n", "<leader>xx", function() MiniExtra.pickers.diagnostic() end, { desc = "Diagnostics picker" })

---- mini.completion + mini.snippets ----
-- Snippets: <C-j> expand, <C-l>/<C-h> jump next/previous placeholder
require("mini.completion").setup({ lsp_completion = { auto_setup = true } })

local MiniSnippets = require("mini.snippets")
MiniSnippets.setup({
    snippets = { MiniSnippets.gen_loader.from_lang() }, -- loads friendly-snippets
})
MiniSnippets.start_lsp_server({ match = false })

---- mini.diff + fugitive (git) ----
local MiniDiff = require("mini.diff")
MiniDiff.setup({ source = MiniDiff.gen_source.git({ index = false }) })

map("n", "<leader>gg", "<cmd>tabnew | Git | only<cr>", { desc = "Fugitive full page in new tab" })
map("n", "<leader>gd", "<cmd>Gvdiffsplit<CR>", { desc = "Git diff split" })
map("n", "<leader>gb", "<cmd>Git blame<cr>", { desc = "Git blame" })
map("n", "<leader>go", function() MiniDiff.toggle_overlay(0) end, { desc = "Toggle diff overlay" })

---- mini.clue (shows available keys after you press <Space>, g, z, [, ] ...) ----
local miniclue = require("mini.clue")
miniclue.setup({
    triggers = {
        { mode = "n", keys = "<Leader>" }, { mode = "x", keys = "<Leader>" },
        { mode = "n", keys = "g" }, { mode = "x", keys = "g" },
        { mode = "n", keys = "z" }, { mode = "x", keys = "z" },
        { mode = "n", keys = "[" }, { mode = "n", keys = "]" },
        { mode = "n", keys = "<C-w>" },
        { mode = "n", keys = "'" }, { mode = "n", keys = "`" },
        { mode = "n", keys = '"' }, { mode = "i", keys = "<C-r>" },
        { mode = "i", keys = "<C-x>" },
    },
    clues = {
        { mode = "n", keys = "<Leader>p", desc = "+Pick / find" },
        { mode = "n", keys = "<Leader>g", desc = "+Git" },
        { mode = "n", keys = "<Leader>l", desc = "+LSP" },
        { mode = "n", keys = "<Leader>b", desc = "+Buffer" },
        { mode = "n", keys = "<Leader>t", desc = "+Toggle / terminal" },
        miniclue.gen_clues.builtin_completion(),
        miniclue.gen_clues.g(),
        miniclue.gen_clues.marks(),
        miniclue.gen_clues.registers(),
        miniclue.gen_clues.windows(),
        miniclue.gen_clues.z(),
    },
    window = { delay = 300 },
})

------------------------------------------------------------
-- Treesitter (needs the `tree-sitter` CLI installed)
------------------------------------------------------------
require("nvim-treesitter").install({
    "go", "rust", "typescript", "javascript", "tsx",
    "html", "css", "json", "bash", "http", "dockerfile",
    "python", "c", "cpp", "java", "zig", "yaml", "toml",
})

vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    pattern = "*",
    callback = function(args)
        local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
        if not lang then return end
        if not pcall(vim.treesitter.language.add, lang) then return end
        pcall(vim.treesitter.start, args.buf, lang)
    end,
})

------------------------------------------------------------
-- LSP
------------------------------------------------------------
require("mason").setup()

-- Diagnostics are OFF by default (clean screen). Toggle them with <leader>td.
vim.diagnostic.config({
    virtual_text = false,
    signs = false,
    underline = false,
    update_in_insert = false,
    severity_sort = true,
    float = { source = true },
})

local diagnostics_on = false
map("n", "<leader>td", function()
    diagnostics_on = not diagnostics_on
    vim.diagnostic.config({
        virtual_text = diagnostics_on and { spacing = 2, prefix = "●" } or false,
        signs = diagnostics_on,
        underline = diagnostics_on,
    })
    vim.notify("Diagnostics " .. (diagnostics_on and "ON" or "OFF"))
end, { desc = "Toggle diagnostics display" })

-- Format on save through the LSP (toggle with <leader>tf)
vim.g.autoformat = true
map("n", "<leader>tf", function()
    vim.g.autoformat = not vim.g.autoformat
    vim.notify("Format on save " .. (vim.g.autoformat and "ON" or "OFF"))
end, { desc = "Toggle format on save" })

vim.api.nvim_create_autocmd("BufWritePre", {
    group = augroup,
    callback = function(args)
        if not vim.g.autoformat then return end
        local clients = vim.lsp.get_clients({ bufnr = args.buf, method = "textDocument/formatting" })
        if #clients > 0 then
            vim.lsp.buf.format({ bufnr = args.buf, timeout_ms = 2000 })
        end
    end,
})

-- LSP keymaps (K = hover, grn rename, gra code action, [d ]d diagnostics are built in)
map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
map("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
map("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
map("n", "gy", vim.lsp.buf.type_definition, { desc = "Go to type definition" })
map("n", "<leader>f", vim.lsp.buf.format, { desc = "Format buffer" })
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show line diagnostics" })
map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol" })
map({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
map("i", "<C-s>", vim.lsp.buf.signature_help, { desc = "Signature help" })
map("n", "<leader>lr", function() MiniExtra.pickers.lsp({ scope = "references" }) end, { desc = "References" })
map("n", "<leader>ls", function() MiniExtra.pickers.lsp({ scope = "document_symbol" }) end, { desc = "Document symbols" })
map("n", "<leader>lS", function() MiniExtra.pickers.lsp({ scope = "workspace_symbol" }) end,
    { desc = "Workspace symbols" })

local capabilities = vim.tbl_deep_extend(
    "force",
    vim.lsp.protocol.make_client_capabilities(),
    require("mini.completion").get_lsp_capabilities()
)
vim.lsp.config("*", { capabilities = capabilities })

vim.lsp.config("lua_ls", {
    settings = { Lua = { diagnostics = { globals = { "vim" } } } },
})

-- Install every server below with one command:  :LspInstallAll
vim.api.nvim_create_user_command("LspInstallAll", function()
    vim.cmd("MasonInstall lua-language-server marksman gopls rust-analyzer clangd pyright "
        .. "typescript-language-server html-lsp css-lsp json-lsp bash-language-server zls")
end, { desc = "Install all configured language servers with Mason" })

-- Only enable servers that are actually installed (no error spam for missing ones)
local servers = {
    "lua_ls", "marksman", "gopls", "rust_analyzer", "clangd", "pyright",
    "ts_ls", "html", "cssls", "jsonls", "bashls", "zls",
}
local enabled = {}
for _, name in ipairs(servers) do
    local cfg = vim.lsp.config[name]
    local cmd = cfg and cfg.cmd
    if type(cmd) == "function" or (type(cmd) == "table" and vim.fn.executable(cmd[1]) == 1) then
        table.insert(enabled, name)
    end
end
vim.lsp.enable(enabled)

------------------------------------------------------------
-- Colorscheme "kitty": uses the same colors as ~/.config/kitty/kitty.conf
-- (dark gray #262626 + Catppuccin Mocha accents), no italics.
-- transparent = true  -> nvim shows Kitty's own background, so they always match.
------------------------------------------------------------
local transparent = true

local function apply_theme()
    local c = {
        bg      = "#262626", -- kitty background
        bg_alt  = "#2e2e2e", -- floats / popup menu
        line    = "#2d2d2d", -- cursor line
        sel     = "#4a4a4a", -- kitty selection_background
        fg      = "#d4d4d4", -- kitty foreground
        white   = "#BAC2DE", -- color7
        gray    = "#A6ADC8", -- color15
        comment = "#6c7086",
        faint   = "#3a3a3a",
        red     = "#F38BA8", -- color1
        green   = "#A6E3A1", -- color2
        yellow  = "#F9E2AF", -- color3
        blue    = "#89B4FA", -- color4
        magenta = "#F5C2E7", -- color5
        cyan    = "#94E2D5", -- color6
        orange  = "#FAB387", -- numbers (Catppuccin peach)
    }
    local bg = transparent and "NONE" or c.bg

    vim.o.termguicolors = true
    vim.o.background = "dark"
    vim.g.colors_name = "kitty"

    local function hl(name, spec)
        spec.italic = false
        vim.api.nvim_set_hl(0, name, spec)
    end
    local function link(name, to) vim.api.nvim_set_hl(0, name, { link = to }) end

    -- Base UI
    hl("Normal", { fg = c.fg, bg = bg })
    hl("NormalNC", { fg = c.fg, bg = bg })
    hl("NormalFloat", { fg = c.fg, bg = c.bg_alt })
    hl("FloatBorder", { fg = c.sel, bg = c.bg_alt })
    hl("FloatTitle", { fg = c.blue, bg = c.bg_alt, bold = true })
    hl("Cursor", { fg = c.bg, bg = c.fg })
    link("lCursor", "Cursor")
    hl("CursorLine", { bg = c.line })
    hl("CursorColumn", { bg = c.line })
    hl("LineNr", { fg = c.comment, bg = bg })
    hl("CursorLineNr", { fg = c.blue, bg = bg, bold = true })
    hl("SignColumn", { bg = bg })
    hl("FoldColumn", { fg = c.comment, bg = bg })
    hl("EndOfBuffer", { fg = c.bg, bg = bg })
    hl("NonText", { fg = c.faint })
    hl("Whitespace", { fg = c.faint })
    hl("WinSeparator", { fg = c.faint, bg = bg })
    hl("VertSplit", { fg = c.faint, bg = bg })
    hl("ColorColumn", { bg = c.line })
    hl("Visual", { bg = c.sel })
    hl("Search", { fg = c.bg, bg = c.yellow })
    hl("CurSearch", { fg = c.bg, bg = c.orange })
    hl("IncSearch", { fg = c.bg, bg = c.orange })
    hl("MatchParen", { fg = c.orange, bg = c.sel, bold = true })
    hl("Directory", { fg = c.blue, bold = true })
    hl("Title", { fg = c.blue, bold = true })
    hl("Folded", { fg = c.comment, bg = c.line })
    hl("ModeMsg", { fg = c.fg })
    hl("MoreMsg", { fg = c.green })
    hl("Question", { fg = c.green })
    hl("ErrorMsg", { fg = c.red })
    hl("WarningMsg", { fg = c.yellow })

    -- Status / tab / popup menu (same grays as the kitty tab bar)
    hl("StatusLine", { fg = c.fg, bg = "#333333" })
    hl("StatusLineNC", { fg = c.comment, bg = "#1c1c1c" })
    hl("TabLine", { fg = "#a0a0a0", bg = "#333333" })
    hl("TabLineSel", { fg = "#ffffff", bg = c.sel, bold = true })
    hl("TabLineFill", { bg = "#1c1c1c" })
    hl("WinBar", { fg = c.fg, bg = bg })
    hl("WinBarNC", { fg = c.comment, bg = bg })
    hl("Pmenu", { fg = c.fg, bg = c.bg_alt })
    hl("PmenuSel", { fg = c.fg, bg = c.sel })
    hl("PmenuSbar", { bg = c.bg_alt })
    hl("PmenuThumb", { bg = c.sel })
    hl("WildMenu", { fg = c.fg, bg = c.sel })

    -- Syntax (classic groups)
    hl("Comment", { fg = c.comment })
    hl("Constant", { fg = c.orange })
    hl("String", { fg = c.green })
    hl("Character", { fg = c.green })
    hl("Number", { fg = c.orange })
    hl("Float", { fg = c.orange })
    hl("Boolean", { fg = c.orange })
    hl("Identifier", { fg = c.fg })
    hl("Function", { fg = c.blue })
    hl("Statement", { fg = c.magenta })
    hl("Conditional", { fg = c.magenta })
    hl("Repeat", { fg = c.magenta })
    hl("Label", { fg = c.magenta })
    hl("Operator", { fg = c.cyan })
    hl("Keyword", { fg = c.magenta })
    hl("Exception", { fg = c.magenta })
    hl("PreProc", { fg = c.cyan })
    hl("Include", { fg = c.magenta })
    hl("Define", { fg = c.magenta })
    hl("Macro", { fg = c.cyan })
    hl("Type", { fg = c.yellow })
    hl("StorageClass", { fg = c.magenta })
    hl("Structure", { fg = c.yellow })
    hl("Typedef", { fg = c.yellow })
    hl("Special", { fg = c.cyan })
    hl("SpecialChar", { fg = c.cyan })
    hl("Delimiter", { fg = c.gray })
    hl("SpecialComment", { fg = c.comment })
    hl("Todo", { fg = c.bg, bg = c.yellow, bold = true })
    hl("Underlined", { fg = c.blue, underline = true })
    hl("Error", { fg = c.red })

    -- Treesitter
    hl("@comment", { fg = c.comment })
    hl("@keyword", { fg = c.magenta })
    hl("@keyword.function", { fg = c.magenta })
    hl("@keyword.return", { fg = c.magenta })
    hl("@keyword.operator", { fg = c.magenta })
    hl("@keyword.import", { fg = c.magenta })
    hl("@keyword.modifier", { fg = c.magenta })
    hl("@keyword.type", { fg = c.magenta })
    hl("@conditional", { fg = c.magenta })
    hl("@repeat", { fg = c.magenta })
    hl("@function", { fg = c.blue })
    hl("@function.call", { fg = c.blue })
    hl("@function.method", { fg = c.blue })
    hl("@function.method.call", { fg = c.blue })
    hl("@function.builtin", { fg = c.cyan })
    hl("@variable", { fg = c.fg })
    hl("@variable.builtin", { fg = c.red })
    hl("@variable.parameter", { fg = c.fg })
    hl("@variable.member", { fg = c.white })
    hl("@property", { fg = c.white })
    hl("@field", { fg = c.white })
    hl("@parameter", { fg = c.fg })
    hl("@constant", { fg = c.orange })
    hl("@constant.builtin", { fg = c.orange })
    hl("@number", { fg = c.orange })
    hl("@number.float", { fg = c.orange })
    hl("@boolean", { fg = c.orange })
    hl("@string", { fg = c.green })
    hl("@string.escape", { fg = c.cyan })
    hl("@character", { fg = c.green })
    hl("@type", { fg = c.yellow })
    hl("@type.builtin", { fg = c.yellow })
    hl("@type.definition", { fg = c.yellow })
    hl("@module", { fg = c.yellow })
    hl("@attribute", { fg = c.yellow })
    hl("@label", { fg = c.magenta })
    hl("@operator", { fg = c.cyan })
    hl("@punctuation", { fg = c.gray })
    hl("@punctuation.bracket", { fg = c.gray })
    hl("@punctuation.delimiter", { fg = c.gray })
    hl("@constructor", { fg = c.yellow })
    hl("@tag", { fg = c.blue })
    hl("@tag.attribute", { fg = c.yellow })
    hl("@tag.delimiter", { fg = c.gray })
    hl("@markup.heading", { fg = c.blue, bold = true })
    hl("@markup.link.url", { fg = c.blue, underline = true })
    hl("@markup.raw", { fg = c.green })
    hl("@markup.strong", { bold = true })
    hl("@markup.italic", { fg = c.fg })

    -- Diagnostics (hidden by default; styled for the float / picker / toggle)
    hl("DiagnosticError", { fg = c.red })
    hl("DiagnosticWarn", { fg = c.yellow })
    hl("DiagnosticInfo", { fg = c.blue })
    hl("DiagnosticHint", { fg = c.cyan })
    hl("DiagnosticOk", { fg = c.green })
    hl("DiagnosticUnderlineError", { undercurl = true, sp = c.red })
    hl("DiagnosticUnderlineWarn", { undercurl = true, sp = c.yellow })

    -- Diff / git
    hl("DiffAdd", { bg = "#2f3d2f" })
    hl("DiffChange", { bg = "#3a3626" })
    hl("DiffDelete", { fg = c.red, bg = "#3d2a2e" })
    hl("DiffText", { bg = "#4a4328" })
    hl("Added", { fg = c.green })
    hl("Changed", { fg = c.yellow })
    hl("Removed", { fg = c.red })
    hl("MiniDiffSignAdd", { fg = c.green })
    hl("MiniDiffSignChange", { fg = c.yellow })
    hl("MiniDiffSignDelete", { fg = c.red })

    -- mini.nvim
    link("MiniFilesNormal", "NormalFloat")
    link("MiniFilesBorder", "FloatBorder")
    hl("MiniFilesCursorLine", { bg = c.sel })
    hl("MiniFilesDirectory", { fg = c.blue, bold = true })
    link("MiniPickNormal", "NormalFloat")
    link("MiniPickBorder", "FloatBorder")
    hl("MiniPickMatchCurrent", { bg = c.sel })
    hl("MiniPickMatchRanges", { fg = c.magenta, bold = true })
    link("MiniNotifyNormal", "NormalFloat")
    link("MiniNotifyBorder", "FloatBorder")
    hl("MiniCompletionActiveParameter", { underline = true })
    hl("MiniTabLineCurrent", { fg = "#ffffff", bg = c.sel, bold = true })
    hl("MiniTabLineVisible", { fg = "#a0a0a0", bg = "#333333" })
    hl("MiniTabLineHidden", { fg = c.comment, bg = "#1c1c1c" })
    hl("MiniTabLineModifiedCurrent", { fg = c.yellow, bg = c.sel, bold = true })
    hl("MiniTabLineModifiedVisible", { fg = c.yellow, bg = "#333333" })
    hl("MiniTabLineModifiedHidden", { fg = c.yellow, bg = "#1c1c1c" })
    hl("MiniTabLineFill", { bg = "#1c1c1c" })
    hl("MiniIndentscopeSymbol", { fg = c.faint })
    hl("MiniCursorword", { underline = true })
    hl("MiniCursorwordCurrent", { underline = true })
    hl("MiniTrailspace", { bg = "NONE", fg = "NONE" }) -- no pink trailing-space blocks
    hl("MiniHipatternsFixme", { fg = c.bg, bg = c.red, bold = true })
    hl("MiniHipatternsHack", { fg = c.bg, bg = c.yellow, bold = true })
    hl("MiniHipatternsTodo", { fg = c.bg, bg = c.blue, bold = true })
    hl("MiniHipatternsNote", { fg = c.bg, bg = c.green, bold = true })
end

apply_theme()
-- Re-apply if some plugin/colorscheme command resets the groups
vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function() vim.schedule(apply_theme) end,
})
