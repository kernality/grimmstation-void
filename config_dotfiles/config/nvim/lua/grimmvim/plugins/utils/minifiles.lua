local function open(path)
  require("mini.files").open(vim.fn.expand(path), true)
end
return {
  "echasnovski/mini.files",
  version = "*",
  event = "VeryLazy",
  opts = {
    options = { permanent_delete = false, use_as_default_explorer = true },
    windows = { preview = true, width_nofocus = 25, width_focus = 30, width_preview = 50 },
  },
  keys = {
    { "<leader>eo", function() local p=vim.api.nvim_buf_get_name(0); open(p ~= "" and p or vim.uv.cwd()) end, desc="MiniFiles current" },
    { "<leader>ee", function() open(vim.uv.cwd()) end, desc="MiniFiles cwd" },
    { "<leader>eH", function() open("~") end, desc="Home" },
    { "<leader>ec", function() open("~/.config/nvim/lua/grimmvim") end, desc="Nvim config" },
    { "<leader>eC", function() open("~/.config") end, desc="Configs" },
    { "<leader>eD", function() open("~/.local/share/config_dotfiles") end, desc="Dotfiles" },
    { "<leader>eB", function() open("~/.local/share/bookmarks") end, desc="Bookmarks" },
  },
  config = function(_, opts) require("mini.files").setup(opts) end,
}
