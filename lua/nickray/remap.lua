-- Misc
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set("i", "jj", "<Esc>") 
vim.keymap.set("n", "<leader>q", vim.cmd.quit)
vim.keymap.set("n", "<leader>qq", "%bd | e # | normal `\"")
vim.keymap.set("n", "<leader>l", ":e #<Enter>")

-- Write commands
vim.keymap.set("n", "<leader>w", vim.cmd.write)
vim.keymap.set("n", "<leader>wa", vim.cmd.wall)
vim.keymap.set("n", "<leader>wq", function()
    vim.cmd.write()
    vim.cmd.quit()
end)

-- Splits
vim.keymap.set("n", "<leader>sv", "<C-w>v")
vim.keymap.set("n", "<leader>sh", "<C-w>s")

-- Replace
vim.keymap.set("n", "<leader>rw", "ciw<C-r>0<Esc>") -- word with buffer
vim.keymap.set("n", "<leader>rf", ":%s/\\<<C-r><C-w>\\>/") -- file
vim.keymap.set("n", "<leader>rb", "yiw[{V%:s/\\<<C-r>0\\>/") -- block

-- Navigation
vim.keymap.set("n", "<leader>tn", "<C-w><C-w>")
vim.keymap.set("n", "<leader>th", "<C-w><C-h>")
