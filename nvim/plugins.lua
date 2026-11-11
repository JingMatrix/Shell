-- macOS bootstrap for the plugins previously installed by hand on Linux.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	local output = vim.fn.system({
		"git",
		"-c",
		"http.connectTimeout=20",
		"-c",
		"http.lowSpeedLimit=1000",
		"-c",
		"http.lowSpeedTime=60",
		"clone",
		"--filter=blob:none",
		"--branch=stable",
		"https://github.com/folke/lazy.nvim.git",
		lazypath,
	})
	if vim.v.shell_error ~= 0 then
		error("Failed to install lazy.nvim; check network access and retry: " .. output)
	end
end
vim.opt.rtp:prepend(lazypath)

local parsers = {
	"bash",
	"c",
	"cpp",
	"css",
	"go",
	"html",
	"java",
	"javascript",
	"json",
	"kotlin",
	"smali",
	"xml",
	"cmake",
	"lua",
	"markdown",
	"markdown_inline",
	"python",
	"rust",
	"toml",
	"tsx",
	"typescript",
	"vim",
	"vimdoc",
	"vue",
	"yaml",
}

require("lazy").setup({
	"tpope/vim-commentary",
	"tpope/vim-fugitive",
	"tpope/vim-rsi",
	"tpope/vim-surround",
	"tpope/vim-unimpaired",
	"tpope/vim-vinegar",
	"lambdalisue/suda.vim",
	"mbbill/undotree",
	"SirVer/ultisnips",
	"honza/vim-snippets",
	"mhinz/vim-startify",
	"vim-airline/vim-airline",
	"vim-airline/vim-airline-themes",
	"ryanoasis/vim-devicons",
	"junegunn/fzf",
	{ "junegunn/fzf.vim", dependencies = { "junegunn/fzf" } },
	{ "ibhagwan/fzf-lua", dependencies = { "nvim-tree/nvim-web-devicons" } },
	"luukvbaal/nnn.nvim",
	"neovim/nvim-lspconfig",
	"nvim-lua/plenary.nvim",
	"mfussenegger/nvim-dap",
	{ "rcarriga/nvim-dap-ui", dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" } },
	{ "mfussenegger/nvim-dap-python", dependencies = { "mfussenegger/nvim-dap" } },
	"jbyuki/one-small-step-for-vimkind",
	"lervag/vimtex",
	{
		"nvim-treesitter/nvim-treesitter",
		branch = vim.fn.has("nvim-0.12") == 1 and "main" or "master",
		build = ":TSUpdate",
		config = function()
			if vim.fn.has("nvim-0.12") == 1 then
				require("nvim-treesitter").setup({})
				vim.api.nvim_create_autocmd("FileType", {
					callback = function(args)
						local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
						if lang and #vim.api.nvim_get_runtime_file("parser/" .. lang .. ".*", false) > 0 then
							vim.treesitter.start(args.buf, lang)
						end
					end,
				})
			else
				require("nvim-treesitter.configs").setup({
					ensure_installed = parsers,
					highlight = { enable = true },
				})
			end
		end,
	},
}, {
	defaults = { lazy = false },
	install = { colorscheme = { "torte" } },
	checker = { enabled = false },
	change_detection = { notify = false },
	rocks = { enabled = false },
	git = { timeout = 120 },
	concurrency = 4,
	headless = { process = false, task = false, log = true, colors = false },
})

vim.api.nvim_create_user_command("InstallParsers", function()
	if vim.fn.has("nvim-0.12") == 1 then
		require("nvim-treesitter").install(parsers):wait(300000)
	else
		vim.cmd("TSInstallSync " .. table.concat(parsers, " "))
	end
	for _, lang in ipairs(parsers) do
		assert(vim.treesitter.language.add(lang), "Parser installation failed: " .. lang)
	end
end, { desc = "Install configured tree-sitter parsers" })
