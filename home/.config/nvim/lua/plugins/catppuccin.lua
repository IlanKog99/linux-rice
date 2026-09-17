-- Catppuccin Mocha, matched to the shell theme.
return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    opts = {
      flavour = "mocha",
      transparent_background = false,
      term_colors = true,
      styles = {
        comments = { "italic" },
        conditionals = { "italic" },
      },
      integrations = {
        blink_cmp = true,
        gitsigns = true,
        indent_blankline = { enabled = true },
        mason = true,
        native_lsp = { enabled = true },
        neotree = true,
        noice = true,
        notify = true,
        semantic_tokens = true,
        telescope = { enabled = true },
        treesitter = true,
        which_key = true,
      },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "catppuccin" },
  },
}
