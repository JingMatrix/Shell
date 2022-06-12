-- mappings.
--

local opts = { noremap = true, silent = true }

-- fzf-vim
vim.api.nvim_set_keymap("n", "<leader><tab>", "<plug>(fzf-maps-n)", opts)
vim.api.nvim_set_keymap("x", "<leader><tab>", "<plug>(fzf-maps-x)", opts)
vim.api.nvim_set_keymap("o", "<leader><tab>", "<plug>(fzf-maps-o)", opts)
vim.api.nvim_set_keymap("i", "<c-x><c-k>", "<plug>(fzf-complete-word)", opts)
vim.api.nvim_set_keymap("i", "<c-x><c-f>", "<plug>(fzf-complete-path)", opts)
vim.api.nvim_set_keymap("i", "<c-x><c-l>", "<plug>(fzf-complete-line)", opts)

vim.api.nvim_set_keymap("n", "<leader>ne", "<cmd>NnnExplorer<CR>", opts)
vim.api.nvim_set_keymap("n", "<leader>np", "<cmd>NnnPicker<CR>", opts)

-- tree-sitter
--
require("nvim-treesitter.configs").setup({
	highlight = {
		enable = true,
		disable = { "latex", "vim", "markdown" },
	},
	indent = {
		enable = true,
	},
	incremental_selection = {
		enable = true,
		keymaps = {
			init_selection = "gnn",
			node_incremental = "grn",
			scope_incremental = "grc",
			node_decremental = "grm",
		},
	},
})

-- nnn
--
require("nnn").setup()

-- vim-lspconfig
--

local lspconfig = require("lspconfig")
-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer

---@diagnostic disable-next-line: unused-local
local lsp_on_attach = function(client, bufnr)
	-- Enable completion triggered by <c-x><c-o>
	vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

	-- Mappings.
	-- See `:help vim.lsp.*` for documentation on any of the below functions
	vim.api.nvim_buf_set_keymap(bufnr, "n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", opts)
	vim.api.nvim_buf_set_keymap(
		bufnr,
		"n",
		"<space>wl",
		"<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>",
		opts
	)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>f", "<cmd>lua vim.lsp.buf.format { async = true }<CR>", opts)

	-- See `:help vim.diagnostic.*` for documentation on any of the below functions
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>e", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>q", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts)

	-- debug using nvim-dap
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>dc", '<cmd>lua require("dap").continue()<CR>', opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>dj", '<cmd>lua require("dap").down()<CR>', opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>dk", '<cmd>lua require("dap").up()<CR>', opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>drc", '<cmd>lua require("dap").run_to_cursor()<CR>', opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>dsv", '<cmd>lua require("dap").step_over()<CR>', opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>dsi", '<cmd>lua require("dap").step_into()<CR>', opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>dso", '<cmd>lua require("dap").step_out()<CR>', opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader><enter>", '<cmd>lua require("dap").toggle_breakpoint()<CR>', opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader><space>", '<cmd>lua require("dapui").eval()<CR>', opts)
	vim.api.nvim_buf_set_keymap(bufnr, "v", "<leader><space>", '<cmd>lua require("dapui").eval()<CR>', opts)
	vim.api.nvim_buf_set_keymap(
		bufnr,
		"n",
		"<leader>dsbr",
		'<cmd>lua require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))<CR>',
		opts
	)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>dro", '<cmd>lua require("dap").repl.open()<CR>', opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>drl", '<cmd>lua require("dap").repl.run_last()<CR>', opts)

	vim.api.nvim_set_keymap("n", "<leader>dg", '<cmd>lua require("dapui").toggle()<CR>', opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>df", '<cmd>lua require("dapui").float_element()<CR>', opts)

	vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>fb", '<cmd>lua require("fzf-lua").dap_breakpoints()<CR>', opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>fc", '<cmd>lua require("fzf-lua").dap_commands()<CR>', opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>fv", '<cmd>lua require("fzf-lua").dap_variables()<CR>', opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>ff", '<cmd>lua require("fzf-lua").dap_frames()<CR>', opts)
end

-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
local lsp_servers = {
	"jedi_language_server",
	-- "pyright",
	"pylsp",
	"vuels",
	"vimls",
	-- "kotlin_language_server",
	"tsserver",
	"racket_langserver",
	"clangd",
	"cmake",
	"gopls",
	"rust_analyzer",
	"solargraph",
	-- Java language server, consider nvim-jdtls when needed
	"jdtls",
}
for _, lsp in pairs(lsp_servers) do
	lspconfig[lsp].setup({
		on_attach = lsp_on_attach,
	})
end

lspconfig.sumneko_lua.setup({
	on_attach = lsp_on_attach,
	settings = {
		Lua = {
			diagnostics = {
				globals = { "vim" },
			},
		},
	},
})

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

for _, lsp in pairs({ "html", "cssls" }) do
	lspconfig[lsp].setup({
		capabilities = capabilities,
		on_attach = lsp_on_attach,
	})
end

-- Debug Adapter
--

local dap = require("dap")
dap.adapters.lldb = {
	type = "executable",
	command = "/usr/bin/lldb-vscode-14", -- adjust as needed, must be absolute path
	name = "lldb",
}

dap.configurations.lua = {
	{
		type = "nlua",
		request = "attach",
		name = "Attach to running Neovim instance",
		host = function()
			local value = vim.fn.input("Host [127.0.0.1]: ")
			if value ~= "" then
				return value
			end
			return "127.0.0.1"
		end,
		port = function()
			local val = tonumber(vim.fn.input("Port: "))
			assert(val, "Please provide a port number")
			return val
		end,
	},
}
dap.configurations.cpp = {
	{
		name = "Launch",
		type = "lldb",
		request = "launch",
		program = function()
			local project_root = vim.lsp.buf.list_workspace_folders()[1]
			vim.api.nvim_set_current_dir(project_root)
			return vim.fn.input("Path to executable: ", project_root .. "/", "file")
		end,
		stopOnEntry = false,
		args = {},
	},
}

dap.configurations.c = dap.configurations.cpp
dap.configurations.rust = dap.configurations.cpp

dap.adapters.nlua = function(callback, config)
	callback({ type = "server", host = config.host, port = config.port })
end

require("dapui").setup({
	sidebar = {
		elements = {
			"repl",
			"watches",
			"breakpoints",
			"stacks",
		},
		size = 40,
		position = "left",
	},
	tray = {
		elements = { "scopes" },
		size = 10,
		position = "bottom",
	},
})

require('dap-python').setup('/usr/bin/python3')
