-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

function ChangeTheme(theme)
    vim.cmd("colorscheme " .. theme)
end

function ColorSchemeSetup(use)
  -- Color Schemes
  use({ "rose-pine/neovim", as = "rose-pine" })
  use({ "rebelot/kanagawa.nvim", as = "kanagawa" })

  -- Kanagawa - Default options:
  require("kanagawa").setup({
      compile = false,             -- enable compiling the colorscheme
      undercurl = true,            -- enable undercurls
      commentStyle = { italic = true },
      functionStyle = {},
      keywordStyle = {},
      statementStyle = {},
      typeStyle = { bold = true },
      transparent = false,         -- do not set background color
      dimInactive = false,         -- dim inactive window `:h hl-NormalNC`
      terminalColors = true,       -- define vim.g.terminal_color_{0,17}
      colors = {                   -- add/modify theme and palette colors
          palette = {},
          theme = {
              all = { ui = { bg_gutter = "none" } }
          },
      },
      overrides = function(colors) -- add/modify highlights
          return {}
      end,
      theme = "wave",              -- Load "wave" theme when "background" option is not set
      background = {               -- map the value of "background" option to a theme
          dark = "wave",           -- try "dragon" !
          light = "lotus"
      },
  })

  -- setup must be called before loading
  vim.cmd("colorscheme kanagawa")
end

return require("packer").startup(function(use)
  use "wbthomason/packer.nvim" -- Packer can manage itself
  use "dense-analysis/ale" -- ALE for linting/fixing
  use("nvim-treesitter/nvim-treesitter", {run = ":TSUpdate"}) -- Syntax highlighting
  use("nvim-treesitter/playground") -- Show AST of file
  use("theprimeagen/harpoon") -- Quick File Switching
  use("theprimeagen/vim-be-good") -- Vim Training plugin
  use("mbbill/undotree") -- Show edit history with branches
  use("tpope/vim-fugitive") -- Git wrapper around Vim Git
  use("folke/zen-mode.nvim") -- Zen mode

  ColorSchemeSetup(use)

  -- Telescope fuzzy finder
  use {
	  "nvim-telescope/telescope.nvim", tag = "0.1.2",
	  requires = { {"nvim-lua/plenary.nvim"} }
  }

  -- LSP and Autocompletion
  use {
	  "VonHeikemen/lsp-zero.nvim",
	  branch = "v1.x",
	  requires = {
		  -- LSP Support
		  {"neovim/nvim-lspconfig"},
		  {"williamboman/mason.nvim"},
		  {"williamboman/mason-lspconfig.nvim"},
		  -- Autocompletion
		  {"hrsh7th/nvim-cmp"},
		  {"hrsh7th/cmp-buffer"},
		  {"hrsh7th/cmp-path"},
		  {"saadparwaiz1/cmp_luasnip"},
		  {"hrsh7th/cmp-nvim-lsp"},
		  {"hrsh7th/cmp-nvim-lua"},
		  -- Snippets
		  {"L3MON4D3/LuaSnip"},
		  {"rafamadriz/friendly-snippets"},
	  }
  }
end)
