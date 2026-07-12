return {
  "mason-org/mason.nvim", lazy = false,
  dependencies = { "WhoIsSethDaniel/mason-tool-installer.nvim" },
  config = function()
    require("mason").setup({ ui = { border = "rounded" } })
    require("mason-tool-installer").setup({
      ensure_installed = {
        "bash-language-server", "lua-language-server", "vim-language-server", "stylua",
        "editorconfig-checker", "html-lsp", "emmet-ls", "css-lsp", "pyright",
        "isort", "black", "json-lsp", "prettier", "biome", "typescript-language-server",
        "js-debug-adapter", "eslint-lsp", "codelldb", "tailwindcss-language-server",
        "clangd", "clang-format", "postgres-language-server", "prisma-language-server", "pgformatter",
      }, auto_update = false, run_on_start = true, start_delay = 3000, debounce_hours = 24,
    })
  end,
}
