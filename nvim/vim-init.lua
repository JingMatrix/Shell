-- mappings.
--

local opts = { noremap = true, silent = true }

-- fzf-vim
vim.keymap.set("n", "<leader><tab>", "<plug>(fzf-maps-n)", opts)
vim.keymap.set("x", "<leader><tab>", "<plug>(fzf-maps-x)", opts)
vim.keymap.set("o", "<leader><tab>", "<plug>(fzf-maps-o)", opts)
vim.keymap.set("i", "<c-x><c-k>", "<plug>(fzf-complete-word)", opts)
vim.keymap.set("i", "<c-x><c-f>", "<plug>(fzf-complete-path)", opts)
vim.keymap.set("i", "<c-x><c-l>", "<plug>(fzf-complete-line)", opts)

vim.keymap.set("n", "<leader>ne", "<cmd>NnnExplorer<CR>", opts)
vim.keymap.set("n", "<leader>np", "<cmd>NnnPicker<CR>", opts)

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

-- registers
--
require("registers").setup()

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
	if vim.bo.filetype ~= "tex" then
		vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
	end

	local bufopts = { noremap = true, silent = true, buffer = bufnr }
	-- Mappings.
	-- See `:help vim.lsp.*` for documentation on any of the below functions
	vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
	vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
	vim.keymap.set("n", "gK", vim.lsp.buf.hover, bufopts)
	vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
	vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, bufopts)
	vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, bufopts)
	vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, bufopts)
	vim.keymap.set("n", "<space>wl", function()
		print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
	end, bufopts)
	vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, bufopts)
	vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, bufopts)
	vim.keymap.set("n", "<space>ca", vim.lsp.buf.code_action, bufopts)
	vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
	vim.keymap.set("n", "<space>f", function()
		vim.lsp.buf.format({ async = true })
	end, bufopts)

	-- See `:help vim.diagnostic.*` for documentation on any of the below functions
	vim.keymap.set("n", "<space>e", vim.diagnostic.open_float, bufopts)
	vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, bufopts)
	vim.keymap.set("n", "]d", vim.diagnostic.goto_next, bufopts)
	vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist, bufopts)

	-- debug using nvim-dap
	vim.keymap.set("n", "<leader>dc", require("dap").continue, bufopts)
	vim.keymap.set("n", "<leader>dj", require("dap").down, bufopts)
	vim.keymap.set("n", "<leader>dk", require("dap").up, bufopts)
	vim.keymap.set("n", "<leader>drc", require("dap").run_to_cursor, bufopts)
	vim.keymap.set("n", "<leader>dsv", require("dap").step_over, bufopts)
	vim.keymap.set("n", "<leader>dsi", require("dap").step_into, bufopts)
	vim.keymap.set("n", "<leader>dso", require("dap").step_out, bufopts)
	vim.keymap.set("n", "<leader><enter>", require("dap").toggle_breakpoint, bufopts)
	vim.keymap.set("n", "<leader>dsbr", function()
		require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
	end, bufopts)
	vim.keymap.set("n", "<leader>dro", require("dap").repl.open, bufopts)
	vim.keymap.set("n", "<leader>drl", require("dap").run_last, bufopts)

	vim.keymap.set("n", "<leader><space>", require("dapui").eval, bufopts)
	vim.keymap.set("v", "<leader><space>", require("dapui").eval, bufopts)
	vim.keymap.set("n", "<leader>dg", require("dapui").toggle, bufopts)
	vim.keymap.set("n", "<leader>df", require("dapui").float_element, bufopts)

	vim.keymap.set("n", "<leader>fb", require("fzf-lua").dap_breakpoints, bufopts)
	vim.keymap.set("n", "<leader>fc", require("fzf-lua").dap_commands, bufopts)
	vim.keymap.set("n", "<leader>fv", require("fzf-lua").dap_variables, bufopts)
	vim.keymap.set("n", "<leader>ff", require("fzf-lua").dap_frames, bufopts)
end

-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
local lsp_servers = {
	-- "jedi_language_server",
	-- "pyright",
	"pylsp",
	"vimls",
	"racket_langserver",
	"clangd",
	-- "ccls",
	"cmake",
	"gopls",
	"marksman",
	"tailwindcss",
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

lspconfig.jdtls.setup({
	on_attach = lsp_on_attach,
	cmd = { "jdtls", "--validate-java-version", "-data", "/home/jing/.cache/jdtls/workspace" },
})

lspconfig.kotlin_language_server.setup({
	on_attach = lsp_on_attach,
	settings = { kotlin = { compiler = { jvm = { target = "21" } } } },
})

lspconfig.denols.setup({
	root_dir = lspconfig.util.root_pattern("deno.json", "deno.jsonc", "deno.lock"),
})

-- lspconfig.tsserver.setup({
-- 	root_dir = lspconfig.util.root_pattern("package.json", "tsconfig.json", "jsconfig.json"),
-- })

lspconfig.lua_ls.setup({
	settings = {
		Lua = {
			diagnostics = {
				globals = { "vim" },
			},
		},
	},
})

lspconfig.volar.setup({
	filetypes = { "vue" },
	init_options = {
		typescript = {
			tsdk = os.getenv("HOME") .. "/.local/share/pnpm/global/5/node_modules/typescript/lib",
		},
	},
})

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

lspconfig.cssls.setup({
	autostart = false,
	capabilities = capabilities,
	on_attach = lsp_on_attach,
})

lspconfig.html.setup({
	capabilities = capabilities,
	on_attach = lsp_on_attach,
})

vim.g.markdown_fenced_languages = {
	"ts=typescript",
}

-- Debug Adapter
--

local dap = require("dap")
dap.adapters.lldb = {
	type = "executable",
	command = "/usr/bin/lldb-dap", -- adjust as needed, must be absolute path
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

require("dap-python").setup("/usr/bin/python3")

require("dapui").setup({
	{
		elements = {
			"scopes",
			"breakpoints",
			"stacks",
			"watches",
		},
		size = 40,
		position = "left",
	},
	{
		elements = {
			"repl",
			"console",
		},
		size = 10,
		position = "bottom",
	},
})

-- ltex config
--
local ltex_languages = {
	"auto",
	"ar",
	"ast-ES",
	"be-BY",
	"br-FR",
	"ca-ES",
	"ca-ES-valencia",
	"da-DK",
	"de",
	"de-AT",
	"de-CH",
	"de-DE",
	"de-DE-x-simple-language",
	"el-GR",
	"en",
	"en-AU",
	"en-CA",
	"en-GB",
	"en-NZ",
	"en-US",
	"en-ZA",
	"eo",
	"es",
	"es-AR",
	"fa",
	"fr",
	"ga-IE",
	"gl-ES",
	"it",
	"ja-JP",
	"km-KH",
	"nl",
	"nl-BE",
	"pl-PL",
	"pt",
	"pt-AO",
	"pt-BR",
	"pt-MZ",
	"pt-PT",
	"ro-RO",
	"ru-RU",
	"sk-SK",
	"sl-SI",
	"sv",
	"ta-IN",
	"tl-PH",
	"uk-UA",
	"zh-CN",
}

local ltex_settings = {
	ltex = {
		enabled = { "markdown", "latex", "mail", "gitcommit" },
		language = "auto",
		additionalRules = {
			motherTongue = "zh-CN",
		},
	},
}

lspconfig.ltex.setup({
	settings = ltex_settings,
	filetypes = { "markdown", "tex", "mail", "gitcommit" },
	single_file_support = true,
	on_attach = function(client, bufnr)
		-- local ft = vim.bo.filetype
		-- if ft == "mail" then
		-- ltex_settings.ltex.language = fr
		-- end
		lsp_on_attach(client, bufnr)
		require("ltex_extra").setup({
			load_langs = { "en-US", "fr", "zh-CN" },
			init_check = true,
			path = vim.fn.stdpath("config") .. "/spell/ltex",
		})
		vim.api.nvim_create_user_command("LtexSwitchLang", function(args)
			local splited_args = vim.split(args.args, " ", { trimemtpy = true })
			ltex_settings.ltex.language = splited_args[1]
			client.notify("workspace/didChangeConfiguration", { setings = ltex_settings })
		end, {
				nargs = 1,
				complete = function(ArgLead, _, _)
					return vim.tbl_filter(function(el)
						return el:find(ArgLead, 1, true)
					end, ltex_languages)
				end,
			})
	end,
})
