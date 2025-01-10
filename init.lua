vim.g.mapleader = " "

-----------------
-- Lazy package manager
-----------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out,                            "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

local ok, lazy = pcall(require, "lazy")

if not ok then
    local msg = "You need to install the plugin manager lazy.nvim\n"
        .. "in this folder: " .. lazypath

    print(msg)
    return
end

lazy.setup({
    { "VonHeikemen/lsp-zero.nvim", branch = "v4.x" },
    { "williamboman/mason.nvim" },
    { "williamboman/mason-lspconfig.nvim" },
    { "neovim/nvim-lspconfig" },
    { "hrsh7th/nvim-cmp" },
    { "hrsh7th/cmp-nvim-lsp" },
    { "hrsh7th/cmp-buffer" },
    { "hrsh7th/cmp-path" },
    { "saadparwaiz1/cmp_luasnip" },
    { "hrsh7th/cmp-nvim-lua" },
    { "L3MON4D3/LuaSnip" },
    { "rafamadriz/friendly-snippets" },
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            local configs = require("nvim-treesitter.configs")

            configs.setup({
                ensure_installed = { "c", "lua", "vim", "vimdoc", "javascript", "html", "go", "vue" },
                sync_install = false,
                highlight = { enable = true },
                indent = { enable = true },
            })
        end
    },
    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.8",
        dependencies = { "nvim-lua/plenary.nvim" }
    },
    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependencies = { "nvim-lua/plenary.nvim" }
    },
    { "folke/tokyonight.nvim" },
    {
        "folke/zen-mode.nvim",
        opts = {
            window = {
                backdrop = 0.99,
                width = 150,
                number = true,
                relativenumber = true,
            }
        }
    },
    { "github/copilot.vim" },
    {
        "toppair/peek.nvim",
        event = { "VeryLazy" },
        build = "deno task --quiet build:fast",
        config = function()
            local peek = require("peek")
            peek.setup()

            vim.api.nvim_create_user_command("PeekOpen", peek.open, {})
            vim.api.nvim_create_user_command("PeekClose", peek.close, {})

            vim.keymap.set("n", "<C-p>", function()
                if peek.is_open() then
                    peek.close()
                else
                    peek.open()
                end
            end)
        end,
    },
})

-----------------
-- LSP Zero
-----------------
local lsp_zero = require("lsp-zero")
local lsp_attach = function(_, bufnr)
    lsp_zero.default_keymaps({ buffer = bufnr, preserve_mappings = false })

    local opts = { buffer = bufnr }
    vim.keymap.set('n', '<leader>d', function() vim.diagnostic.open_float() end, opts)
    vim.keymap.set('n', '[d', function() vim.diagnostic.goto_next() end, opts)
    vim.keymap.set('n', ']d', function() vim.diagnostic.goto_prev() end, opts)
    vim.keymap.set('n', '<leader>vca', function() vim.lsp.buf.code_action() end, opts)
    vim.keymap.set('n', '<leader>vrr', function() vim.lsp.buf.references() end, opts)
    vim.keymap.set('n', '<leader>vrn', function() vim.lsp.buf.rename() end, opts)
end
lsp_zero.extend_lspconfig({
    capabilities = require("cmp_nvim_lsp").default_capabilities(),
    float_border = "rounded",
    lsp_attach = lsp_attach,
    sign_text = true,
})

-----------------
-- Mason
-----------------
require("mason").setup({})
require("mason-lspconfig").setup({
    ensure_installed = { "eslint", "gopls", "lua_ls", "volar" },
    handlers = {
        function(server_name)
            require("lspconfig")[server_name].setup({})
        end,
        lua_ls = function()
            local lua_opts = lsp_zero.nvim_lua_ls()
            require("lspconfig").lua_ls.setup(lua_opts)
        end,
    }
})

lsp_zero.set_sign_icons({
    error = "✘",
    warn = "▲",
    hint = "⚑",
    info = ""
})

vim.diagnostic.config({
    virtual_text = false,
    severity_sort = true,
    float = {
        style = "minimal",
        border = "rounded",
        source = "always",
        header = "",
        prefix = "",
    },
})

local cmp = require("cmp")
local cmp_action = lsp_zero.cmp_action()

require("luasnip.loaders.from_vscode").lazy_load()

vim.opt.completeopt = { "menu", "menuone", "noselect" }

cmp.setup({
    formatting = lsp_zero.cmp_format({ details = true }),
    preselect = "item",
    completion = {
        completeopt = "menu,menuone,noinsert"
    },
    window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
    },
    sources = {
        { name = "path" },
        { name = "nvim_lsp" },
        { name = "nvim_lua" },
        { name = "buffer",  keyword_length = 3 },
        { name = "luasnip", keyword_length = 2 },
    },
    mapping = cmp.mapping.preset.insert({
        -- confirm completion item
        ["<CR>"] = cmp.mapping.confirm({ select = false }),

        -- toggle completion menu
        ["<C-e>"] = cmp_action.toggle_completion(),

        -- tab complete
        ["<Tab>"] = cmp_action.tab_complete(),
        ["<S-Tab>"] = cmp.mapping.select_prev_item(),

        -- navigate between snippet placeholder
        ["<C-d>"] = cmp_action.luasnip_jump_forward(),
        ["<C-b>"] = cmp_action.luasnip_jump_backward(),

        -- scroll documentation window
        ["<C-f>"] = cmp.mapping.scroll_docs(5),
        ["<C-u>"] = cmp.mapping.scroll_docs(-5),
    }),
    snippet = {
        expand = function(args)
            require("luasnip").lsp_expand(args.body)
        end,
    },
})

-----------------
-- Harpoon
-----------------
local harpoon = require("harpoon")

vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

vim.keymap.set("n", "<C-h>", function() harpoon:list():select(1) end)
vim.keymap.set("n", "<C-t>", function() harpoon:list():select(2) end)
vim.keymap.set("n", "<C-n>", function() harpoon:list():select(3) end)
vim.keymap.set("n", "<C-s>", function() harpoon:list():select(4) end)

-- Toggle previous & next buffers stored within Harpoon list
vim.keymap.set("n", "<C-S-P>", function() harpoon:list():prev() end)
vim.keymap.set("n", "<C-S-N>", function() harpoon:list():next() end)

-----------------
-- Telescope
-----------------
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>pf", builtin.find_files, {})
vim.keymap.set("n", "<leader>ps", function()
    builtin.grep_string({ search = vim.fn.input("Grep > ") })
end)

-----------------
-- Zen Mode
-----------------
vim.keymap.set("n", "<leader>zz", function () require("zen-mode").toggle() end)

-----------------
-- Vim Settings
-----------------
vim.opt.guicursor = ""

vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.expandtab = true

function SetTab(size)
    vim.opt.tabstop = size
    vim.opt.softtabstop = size
    vim.opt.shiftwidth = size
end

SetTab(4)

vim.opt.splitright = true

vim.opt.smartindent = true

vim.opt.wrap = true

vim.opt.swapfile = false
vim.opt.backup = false
--vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true
vim.cmd.colorscheme("tokyonight")

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.opt.colorcolumn = "100"

-- Use Treesitter"s fold expression
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"

-- Case insensitive directory sorting
vim.g.netrw_sort_options = "i"

-----------------
-- Remaps
-----------------
-- Misc
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set("i", "jj", "<Esc>")                          -- Exit insert mode
vim.keymap.set("t", "jj", "<C-/><C-n>")                     -- Exit insert mode from terminal mode
vim.keymap.set("n", "<leader>q", vim.cmd.quit)              -- Quit
vim.keymap.set("n", "<leader>qq", "%bd | e # | normal `\"") -- Quit all
vim.keymap.set("n", "<leader>l", ":e #<Enter>")             -- Edit last file
vim.keymap.set("n", "<leader>e", ":e<Enter>")               -- Reload file, helpful if LSP crashes
vim.keymap.set("n", "<leader><leader>y", "\"+yiw")          -- Yank word to system clipboard
vim.keymap.set("v", "<leader><leader>y", "\"+y")            -- Yank highlighted text to system clipboard
vim.keymap.set({"n", "v"}, "<leader><leader>p", "\"+p")     -- Past from system clipboard

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
vim.keymap.set("n", "<leader>rw", "ciw<C-r>0<Esc>")          -- word with buffer
vim.keymap.set("n", "<leader>rf", ":%s/\\<<C-r><C-w>\\>/")   -- file
vim.keymap.set("n", "<leader>rb", "yiw[{V%:s/\\<<C-r>0\\>/") -- block

-- Navigation
vim.keymap.set("n", "<leader>tn", "<C-w><C-w>")
vim.keymap.set("n", "<leader>th", "<C-w><C-h>")

-- Copilot
-- accept suggestion
vim.keymap.set('i', '<C-J>', 'copilot#Accept("\\<CR>")', {
    expr = true,
    replace_keycodes = false
})
vim.g.copilot_no_tab_map = true

-- accept one word of suggestion
vim.keymap.set('i', '<C-L>', '<Plug>(copilot-accept-word)')
