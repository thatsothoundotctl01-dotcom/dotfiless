-- code_runner (F6 = run current file, F7 = close runner)
-- Placeholders: $dir, $fileName, $fileNameWithoutExt
require("code_runner").setup({
    mode = "term",
    focus = true,
    startinsert = false,
    term = { position = "bot", size = 12 },
    filetype = {
        -- scripting
        python     = "cd $dir && python3 -u $fileName",
        javascript = "cd $dir && node $fileName",
        typescript = "cd $dir && npx tsx $fileName",
        lua        = "cd $dir && nvim -l $fileName",
        sh         = "cd $dir && bash $fileName",
        bash       = "cd $dir && bash $fileName",
        php        = "cd $dir && php $fileName",
        ruby       = "cd $dir && ruby $fileName",
        perl       = "cd $dir && perl $fileName",
        -- compiled
        go   = "cd $dir && go run $fileName",
        rust = "cd $dir && rustc $fileName -o /tmp/$fileNameWithoutExt && /tmp/$fileNameWithoutExt",
        c    = "cd $dir && gcc $fileName -o /tmp/$fileNameWithoutExt && /tmp/$fileNameWithoutExt",
        cpp  = "cd $dir && g++ $fileName -o /tmp/$fileNameWithoutExt && /tmp/$fileNameWithoutExt",
        java = "cd $dir && javac $fileName && java $fileNameWithoutExt",
        zig  = "cd $dir && zig run $fileName",
        -- For Go/Rust projects with several files, swap the lines above for:
        -- go   = "cd $dir && go run .",
        -- rust = "cd $dir && cargo run",
    },
})

vim.keymap.set("n", "<F6>", function()
    if vim.api.nvim_buf_get_name(0) == "" then
        vim.notify("Save the file first", vim.log.levels.WARN)
        return
    end
    if vim.bo.modified then vim.cmd("silent write") end
    require("code_runner").run_code()
end, { desc = "Run current file" })
vim.keymap.set("n", "<F7>", "<cmd>RunClose<cr>", { desc = "Close code runner window" })
