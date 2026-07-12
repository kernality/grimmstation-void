return {
	"stevearc/conform.nvim",
	event = { "InsertEnter", "LspAttach" },
	opts = {
		formatters_by_ft = {
			javascript = { "biome" },
			typescript = { "biome" },
			javascriptreact = { "biome" },
			typescriptreact = { "biome" },
			json = { "biome" },
			jsonc = { "biome" },
			svelte = { "prettier" },
			css = { "biome" },
			html = { "prettier" },
			yaml = { "prettier" },
			markdown = { "prettier" },
			graphql = { "prettier" },
			liquid = { "prettier" },
			lua = { "stylua" },
			python = { "isort", "black" },
			sql = { "pg_format" },
		},
		formatters = {
			pg_format = {
				prepend_args = { "-s", "2" },
			},
		},
		format_on_save = {
			lsp_format = "fallback",
			async = false,
			timeout_ms = 3000,
		},
	},
	keys = {
		{
			mode = { "n", "v" },
			"<leader>Fm",
			function()
				require("conform").format({
					lsp_format = "fallback",
					timeout_ms = 3000,
				})
			end,
			desc = "Conform: Format Manually",
		},
	},
}
