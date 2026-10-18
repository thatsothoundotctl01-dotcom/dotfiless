-- ~/.config/nvim/init.lua
-- Developer-focused single-file config for Neovim 0.12+
-- Goal: write code fast. Leader = <Space>. Press <Space> and wait for key hints.
-- Theme: VS Code Dark+ look (vscode.nvim) + blue VS Code statusline.

local ok_ui2, ui2 = pcall(require, "vim._core.ui2")
if ok_ui2 then ui2.enable({}) end

------------------------------------------------------------
-- Options
------------------------------------------------------------
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

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
    "https://github.com/Mofiqul/vscode.nvim",     -- VS Code Dark+ colorscheme
    "https://github.com/windwp/nvim-ts-autotag",  -- auto close/rename HTML & JSX tags
    "https://github.com/nvim-tree/nvim-tree.lua", -- VS Code style sidebar explorer
    "https://github.com/okuuva/auto-save.nvim",   -- auto-save plugin
})


---- code_runner (F6 = run current file inside nvim, F7 = close output) ----
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

------------------------------------------------------------
-- Auto-save + auto-run in the tmux right pane
------------------------------------------------------------
-- Auto-save plugin (okuuva/auto-save.nvim)
--   saves 1s after you stop typing / leave insert mode, immediately on buffer or focus change
require("auto-save").setup({
    enabled = true,
    trigger_events = {
        immediate_save = { "BufLeave", "FocusLost" },
        defer_save = { "InsertLeave", "TextChanged" },
        cancel_deferred_save = { "InsertEnter" },
    },
    -- only real, editable files (skips sidebar, pickers, terminals, help ...)
    condition = function(buf)
        local b = vim.bo[buf]
        return b.modifiable and b.buftype == "" and vim.api.nvim_buf_get_name(buf) ~= ""
            and b.filetype ~= "NvimTree" and b.filetype ~= "minifiles"
    end,
    debounce_delay = 1000, -- ms; raise it if auto-run fires too often
})

-- skip LSP format-on-save during autosaves (it moves your code while you type)
local autosave_prev_format
vim.api.nvim_create_autocmd("User", {
    group = augroup,
    pattern = "AutoSaveWritePre",
    callback = function()
        autosave_prev_format = vim.g.autoformat
        vim.g.autoformat = false
    end,
})
vim.api.nvim_create_autocmd("User", {
    group = augroup,
    pattern = "AutoSaveWritePost",
    callback = function()
        if autosave_prev_format ~= nil then vim.g.autoformat = autosave_prev_format end
    end,
})

map("n", "<leader>ta", "<cmd>ASToggle<cr>", { desc = "Toggle auto-save" })

-- Run command per filetype. Placeholders: {file} {dir} {name} {bin}
local run_cmds = {
    c          = "gcc {file} -o {bin} && {bin}",
    cpp        = "g++ -std=c++17 {file} -o {bin} && {bin}",
    python     = "python3 -u {file}",
    javascript = "node {file}",
    typescript = "npx tsx {file}",
    lua        = "nvim -l {file}",
    sh         = "bash {file}",
    bash       = "bash {file}",
    zsh        = "zsh {file}",
    php        = "php {file}",
    ruby       = "ruby {file}",
    perl       = "perl {file}",
    go         = "go run {file}",
    rust       = "rustc {file} -o {bin} && {bin}",
    java       = "javac {file} && java -cp {dir} {name}",
    kotlin     = "kotlinc {file} -include-runtime -d {bin}.jar && java -jar {bin}.jar",
    zig        = "zig run {file}",
    swift      = "swiftc {file} -o {bin} && {bin}",
    dart       = "dart run {file}",
    r          = "Rscript {file}",
    haskell    = "runghc {file}",
    cs         = "mcs {file} -out:{bin}.exe && mono {bin}.exe",
    scala      = "scala {file}",
    elixir     = "elixir {file}",
    julia      = "julia {file}",
    nim        = "nim compile --run -o:{bin} {file}",
}

-- Which tmux pane gets the command. Default: the pane to the right of nvim.
-- Override with  :let g:run_pane = "1"  (any tmux target, see `tmux display-panes`)
local function tmux_target() return vim.g.run_pane or "{right-of}" end

local function send_to_tmux(buf)
    if vim.env.TMUX == nil then
        return vim.notify("Not inside tmux", vim.log.levels.WARN)
    end
    local ft = vim.bo[buf].filetype
    local tpl = run_cmds[ft]
    if not tpl then
        return vim.notify("No run command for filetype: " .. ft, vim.log.levels.WARN)
    end
    local path = vim.api.nvim_buf_get_name(buf)
    local name = vim.fn.fnamemodify(path, ":t:r")
    local esc = vim.fn.shellescape
    local cmd = tpl
        :gsub("{file}", function() return esc(path) end)
        :gsub("{dir}", function() return esc(vim.fn.fnamemodify(path, ":h")) end)
        :gsub("{name}", function() return name end)
        :gsub("{bin}", function() return esc("/tmp/" .. name) end)
    cmd = "clear; cd " .. esc(vim.fn.fnamemodify(path, ":h")) .. " && " .. cmd

    local t = tmux_target()
    vim.system({
        "tmux",
        "send-keys", "-t", t, "C-c", ";",     -- stop the previous run
        "send-keys", "-t", t, "-l", cmd, ";", -- type the command
        "send-keys", "-t", t, "Enter",
    })
end

-- Auto-run after every save (toggle with <leader>tr)
vim.g.autorun = true
vim.api.nvim_create_autocmd("BufWritePost", {
    group = augroup,
    desc = "Compile/run in tmux right pane",
    callback = function(args)
        if vim.g.autorun and vim.bo[args.buf].buftype == "" then
            send_to_tmux(args.buf)
        end
    end,
})
map("n", "<leader>tr", function()
    vim.g.autorun = not vim.g.autorun
    vim.notify("Auto-run " .. (vim.g.autorun and "ON" or "OFF"))
end, { desc = "Toggle auto-run on save" })

-- Manual run in the tmux pane
map("n", "<F8>", function() send_to_tmux(vim.api.nvim_get_current_buf()) end,
    { desc = "Run in tmux right pane" })

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

---- nvim-tree: VS Code style sidebar ----
-- F5 = toggle sidebar, <leader>E = reveal current file, `-` = mini.files popup (unchanged)
local function nvimtree_on_attach(bufnr)
    local api = require("nvim-tree.api")
    api.config.mappings.default_on_attach(bufnr)
    local function o(desc)
        return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
    end
    pcall(vim.keymap.del, "n", "<C-k>", { buffer = bufnr }) -- keep <C-k> window navigation
    map("n", "l", api.node.open.edit, o("Open"))
    map("n", "<CR>", api.node.open.edit, o("Open"))
    map("n", "h", api.node.navigate.parent_close, o("Close folder"))
    map("n", "v", api.node.open.vertical, o("Open in vertical split"))
    map("n", "q", api.tree.close, o("Close sidebar"))
end

require("nvim-tree").setup({
    on_attach = nvimtree_on_attach,
    hijack_cursor = true,
    sync_root_with_cwd = true,
    update_focused_file = { enable = true }, -- follow the file you are editing
    view = { width = 32, side = "left", signcolumn = "yes" },
    renderer = {
        group_empty = true,
        highlight_git = "name",
        indent_width = 2,
        root_folder_label = function(path) return vim.fn.fnamemodify(path, ":t"):upper() end,
        indent_markers = {
            enable = true,
            icons = { corner = "└", edge = "│", item = "│", bottom = "─", none = " " },
        },
        icons = {
            git_placement = "after",
            modified_placement = "after",
            show = { file = true, folder = false, folder_arrow = true, git = true, modified = true },
            glyphs = {
                modified = "●",
                folder = {
                    arrow_closed = vim.fn.nr2char(0xf054), -- chevron right
                    arrow_open = vim.fn.nr2char(0xf078),   -- chevron down
                },
                git = {
                    unstaged = "M",
                    staged = "A",
                    unmerged = "!",
                    renamed = "R",
                    untracked = "U",
                    deleted = "D",
                    ignored = "◌",
                },
            },
        },
    },
    diagnostics = {
        enable = true,
        show_on_dirs = false,
        icons = { hint = "●", info = "●", warning = "●", error = "●" },
    },
    git = { enable = true, ignore = false },
    modified = { enable = true },
    filters = { dotfiles = false },
    actions = { open_file = { quit_on_open = false, window_picker = { enable = false } } },
})

map("n", "<F5>", "<cmd>NvimTreeToggle<cr>", { desc = "Toggle sidebar explorer" })
map("n", "<leader>E", "<cmd>NvimTreeFindFile<cr>", { desc = "Reveal current file in sidebar" })

-- close nvim when the sidebar is the last window left
vim.api.nvim_create_autocmd("BufEnter", {
    group = augroup,
    nested = true,
    callback = function()
        if #vim.api.nvim_list_wins() == 1 and vim.bo.filetype == "NvimTree" then
            vim.cmd("quit")
        end
    end,
})

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

---- mini.statusline (VS Code style bottom bar) ----
require("mini.statusline").setup({ use_icons = true })

---- nvim-ts-autotag (needs treesitter html/tsx parsers) ----
require("nvim-ts-autotag").setup()

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
-- Colorscheme: VS Code Dark+ (vscode.nvim)
-- Transparent by default. Toggle with <leader>tT.
-- Blur itself comes from the TERMINAL (kitty/alacritty opacity + blur), not from nvim.
-- nvim only makes its own background transparent and lets popups/floats see through (winblend).
------------------------------------------------------------
local transparent = true

-- Extra highlights for mini.nvim + VS Code statusline (re-applied after every :colorscheme)
local function apply_extras()
    local c = {
        bg_alt = "#252526",
        sel = "#264F78",
        line = "#2A2D2E",
        faint = "#404040",
        fg = "#D4D4D4",
        comment = "#6A9955",
        gray = "#858585",
        red = "#F44747",
        green = "#6A9955",
        yellow = "#DCDCAA",
        blue = "#569CD6",
        cyan = "#4EC9B0",
        orange = "#CE9178",
        purple = "#C586C0",
        vsblue = "#007ACC",
    }
    local function hl(name, spec) vim.api.nvim_set_hl(0, name, spec) end
    local function link(name, to) vim.api.nvim_set_hl(0, name, { link = to }) end

    -- backgrounds that go transparent (so the terminal blur shows through)
    local side_bg = transparent and "NONE" or "#252526"
    local tab_bg = transparent and "NONE" or "#2D2D2D"
    local tab_cur = transparent and "#2F2F2F" or "#1F1F1F"

    hl("NormalFloat", { fg = c.fg, bg = c.bg_alt })
    hl("FloatBorder", { fg = c.faint, bg = c.bg_alt })
    hl("Pmenu", { fg = c.fg, bg = c.bg_alt })
    hl("PmenuSel", { fg = "#FFFFFF", bg = c.sel })
    hl("CursorLine", { bg = c.line })
    hl("Visual", { bg = c.sel })
    hl("WinSeparator", { fg = c.faint })

    -- statusline: classic VS Code blue bar
    hl("StatusLine", { fg = "#FFFFFF", bg = c.vsblue })
    hl("StatusLineNC", { fg = c.gray, bg = "#333333" })
    hl("MiniStatuslineModeNormal", { fg = "#FFFFFF", bg = "#005F9E", bold = true })
    hl("MiniStatuslineModeInsert", { fg = "#FFFFFF", bg = "#16825D", bold = true })
    hl("MiniStatuslineModeVisual", { fg = "#FFFFFF", bg = "#8A4BA8", bold = true })
    hl("MiniStatuslineModeReplace", { fg = "#FFFFFF", bg = "#C72E2E", bold = true })
    hl("MiniStatuslineModeCommand", { fg = "#FFFFFF", bg = "#B07F00", bold = true })
    hl("MiniStatuslineModeOther", { fg = "#FFFFFF", bg = "#555555", bold = true })
    hl("MiniStatuslineDevinfo", { fg = "#FFFFFF", bg = c.vsblue })
    hl("MiniStatuslineFilename", { fg = "#FFFFFF", bg = c.vsblue })
    hl("MiniStatuslineFileinfo", { fg = "#FFFFFF", bg = c.vsblue })
    hl("MiniStatuslineInactive", { fg = c.gray, bg = "#333333" })

    -- tabline: VS Code editor tabs
    hl("MiniTabLineCurrent", { fg = "#FFFFFF", bg = tab_cur, bold = true })
    hl("MiniTabLineVisible", { fg = c.gray, bg = tab_bg })
    hl("MiniTabLineHidden", { fg = c.gray, bg = tab_bg })
    hl("MiniTabLineModifiedCurrent", { fg = c.yellow, bg = tab_cur, bold = true })
    hl("MiniTabLineModifiedVisible", { fg = c.yellow, bg = tab_bg })
    hl("MiniTabLineModifiedHidden", { fg = c.yellow, bg = tab_bg })
    hl("MiniTabLineFill", { bg = side_bg })

    -- mini.nvim widgets
    link("MiniFilesNormal", "NormalFloat")
    link("MiniFilesBorder", "FloatBorder")
    hl("MiniFilesCursorLine", { bg = c.sel })
    hl("MiniFilesDirectory", { fg = c.blue, bold = true })
    link("MiniPickNormal", "NormalFloat")
    link("MiniPickBorder", "FloatBorder")
    hl("MiniPickMatchCurrent", { bg = c.sel })
    hl("MiniPickMatchRanges", { fg = c.yellow, bold = true })
    link("MiniNotifyNormal", "NormalFloat")
    link("MiniNotifyBorder", "FloatBorder")
    hl("MiniCompletionActiveParameter", { underline = true })
    hl("MiniIndentscopeSymbol", { fg = "#707070" })
    hl("MiniCursorword", { bg = "#343A40" })
    hl("MiniCursorwordCurrent", { bg = "#343A40" })
    hl("MiniTrailspace", { bg = "NONE", fg = "NONE" })

    -- sidebar explorer (VS Code: #252526 background, #37373D selection)
    hl("NvimTreeNormal", { fg = "#CCCCCC", bg = side_bg })
    hl("NvimTreeNormalNC", { fg = "#CCCCCC", bg = side_bg })
    hl("NvimTreeEndOfBuffer", { fg = side_bg, bg = side_bg })
    hl("NvimTreeWinSeparator", { fg = "#404040", bg = side_bg })
    hl("NvimTreeCursorLine", { bg = "#37373D" })
    hl("NvimTreeRootFolder", { fg = "#CCCCCC", bold = true })
    hl("NvimTreeFolderName", { fg = "#CCCCCC" })
    hl("NvimTreeOpenedFolderName", { fg = "#CCCCCC" })
    hl("NvimTreeEmptyFolderName", { fg = "#CCCCCC" })
    hl("NvimTreeFolderArrowClosed", { fg = "#C5C5C5" })
    hl("NvimTreeFolderArrowOpen", { fg = "#C5C5C5" })
    hl("NvimTreeIndentMarker", { fg = "#404040" })
    hl("NvimTreeSpecialFile", { fg = "#CCCCCC", underline = false })
    hl("NvimTreeExecFile", { fg = "#CCCCCC" })
    hl("NvimTreeGitDirtyIcon", { fg = "#E2C08D" })
    hl("NvimTreeGitStagedIcon", { fg = "#73C991" })
    hl("NvimTreeGitNewIcon", { fg = "#73C991" })
    hl("NvimTreeGitDeletedIcon", { fg = "#C74E39" })
    hl("NvimTreeGitIgnoredIcon", { fg = "#8C8C8C" })
    hl("NvimTreeGitFileDirtyHL", { fg = "#E2C08D" })
    hl("NvimTreeGitFileNewHL", { fg = "#73C991" })
    hl("NvimTreeGitFileStagedHL", { fg = "#73C991" })
    hl("NvimTreeGitFileDeletedHL", { fg = "#C74E39" })
    hl("NvimTreeGitFileIgnoredHL", { fg = "#8C8C8C" })
    hl("NvimTreeModifiedIcon", { fg = "#E2C08D" })

    -- git signs
    hl("MiniDiffSignAdd", { fg = "#587C0C" })
    hl("MiniDiffSignChange", { fg = "#0C7D9D" })
    hl("MiniDiffSignDelete", { fg = "#94151B" })

    -- TODO / FIXME highlights
    hl("MiniHipatternsFixme", { fg = "#1F1F1F", bg = c.red, bold = true })
    hl("MiniHipatternsHack", { fg = "#1F1F1F", bg = c.yellow, bold = true })
    hl("MiniHipatternsTodo", { fg = "#1F1F1F", bg = c.blue, bold = true })
    hl("MiniHipatternsNote", { fg = "#1F1F1F", bg = c.green, bold = true })
end

local function load_theme()
    require("vscode").setup({
        style = "dark",
        transparent = transparent,
        italic_comments = false,
        italic_inlayhints = false,
        underline_links = true,
        terminal_colors = true,
    })
    vim.cmd.colorscheme("vscode")
    -- see-through popups / floats / completion menu when transparent
    vim.o.winblend = transparent and 12 or 0
    vim.o.pumblend = transparent and 12 or 0
    apply_extras()
end

load_theme()
-- Re-apply extras if any colorscheme command resets groups
vim.api.nvim_create_autocmd("ColorScheme", {
    group = augroup,
    callback = function() vim.schedule(apply_extras) end,
})

map("n", "<leader>tT", function()
    transparent = not transparent
    load_theme()
    vim.notify("Transparent background " .. (transparent and "ON" or "OFF"))
end, { desc = "Toggle transparent background" })
