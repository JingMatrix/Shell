" vimtex
let g:vimtex_compiler_method='latexmk'
let g:vimtex_quickfix_method='pplatex'
let g:vimtex_compiler_latexmk={'build_dir' : '/var/tmp/latex',
			\'options' : [
				\'-verbose',
				\'-bibtex',
				\'-synctex=1',
				\'-interaction=nonstopmode'
				\]}
let g:vimtex_fold_enabled=1
let g:vimtex_fold_manual=1
let g:vimtex_view_method='zathura'
let g:vimtex_log_ignore=['Viewer cannot find Zathura window ID!']
let g:matchup_override_vimtex=1
let g:vimtex_quickfix_open_on_warning=0
let g:vimtex_quickfix_ignore_filters=['(Package hyperref) Token not', 'Fandol']
let g:vimtex_syntax_custom_cmds=[
			\{'name': 'YYCleverefInput', 'argspell': 0}
			\]
let g:vimtex_syntax_nospell_comments=1
let g:vimtex_grammar_vlty={'lt_command': 'languagetool'}
let g:vimtex_indent_bib_enabled=0
let g:vimtex_doc_handlers = ['vimtex#doc#handlers#texdoc']
let g:vimtex_fold_types={'comments' : {'enabled' : 1}}
augroup math_edit
	autocmd!
	autocmd FileType tex nmap <buffer> <F9> :setl spell <bar> silent! w <bar> compiler vlty <bar> make <bar> :cw <cr><esc>
	autocmd FileType tex setl dictionary+=../.dict | setl iskeyword+=- | setl complete=.,t,k
	" Specify extra behaviour after reverse goto
	autocmd User VimtexEventViewReverse normal! zMzvzz
augroup end

" startify
let g:startify_change_to_dir=1
let g:startify_change_to_vcs_root=1
let g:startify_skiplist=['doc/.*\.txt$', '.*/tmp/*', 'Notes/notes/.*\.md$', 'Code/Shell/.*']
let g:startify_files_number=5
let g:startify_bookmarks=[
			\{'n': '$HOME/Notes'},
			\{'c': '$HOME/Documents/Code/Shell'},
			\{'z': '$HOME/Documents/Code/Shell/.zshrc'},
			\{'k': '$HOME/Documents/Code/Shell/kitty.conf'},
			\{'s': '$HOME/.config/sway/config'},
			\{'v': '$HOME/.config/nvim/init.vim'},
			\{'a': '$HOME/.config/alacritty/alacritty.yml'},
			\]
let g:startify_lists=[
			\{ 'type': 'sessions',  'header': ['   Sessions']       },
			\{ 'type': 'bookmarks', 'header': ['   Bookmarks']      },
			\{ 'type': 'files',	'header': ['   MRU'] },
			\]
let g:startify_custom_header_quotes=[
			\['Where is your improvement in five years?'],
			\['Do you feel sorry about yourself?'],
			\['Are you escaping from yourself?']]
nnoremap <c-h> :Startify<cr><esc>

" Airline
let g:airline_theme='apprentice'
let g:airline#extensions#whitespace#skip_indent_check_ft={'tex': ['indent']}
let g:airline_powerline_fonts=1
let g:airline#extensions#tabline#enabled=1
let g:airline#extensions#tabline#buffer_min_count=2

" Netrw
let g:netrw_sort_by='time'
let g:netrw_sort_direction='reverse'
let g:netrw_preview=1
let g:netrw_liststyle=3
let g:netrw_winsize=30

" mkdx
let g:mkdx#settings={'highlight': {'enable': 1},
			\'enter': {'enable': 0},
			\'fold': {'enable': 1}}

" vim-markdown
let g:vim_markdown_frontmatter=1
let g:vim_markdown_follow_anchor=1
let g:vim_markdown_folding_level=4
let g:vim_markdown_toc_autofit=1
let g:vim_markdown_strikethrough=1
let g:vim_markdown_math=1
augroup markdown_workaround
	autocmd!
	autocmd FileType checkhealth let g:vim_markdown_math=0
augroup END

" sudo edit
let g:suda_smart_edit=0

" Add system path if not presented
if stridx($PATH, 'node')==-1
	let $PATH .=':/home/jing/.nvm/versions/node/v18.1.0/bin'
endif

" formater
augroup formatter
	autocmd!
	autocmd FileType sh,zsh,bash setl formatprg=shfmt\ -ln\ bash\ -filename\ %
	autocmd FileType python setl formatprg=yapf
	autocmd FileType lua setl formatprg=stylua\ -\ -
	autocmd FileType tex,bib setl formatprg=latexindent\ -m\ -c=/tmp/
	autocmd FileType javascript,html,vue,markdown,css,xhtml,scss,xml setl formatprg=prettier\ --stdin-filepath\ %
	autocmd FileType json,jsonc setl formatprg=jq\ '.'
augroup END


" input Chinese
function ToggleChineseInput()
	if !exists('#chinese#InsertEnter')
		augroup chinese
			autocmd! * <buffer>
			autocmd InsertEnter <buffer> silent !fcitx5-remote -c &>/dev/null
			autocmd InsertLeave <buffer> silent !fcitx5-remote -o &>/dev/null
		augroup END
	else
		augroup chinese
			autocmd! * <buffer>
		augroup END
	endif
endfunction
nmap yoz :call ToggleChineseInput()<cr>
augroup toggles
	autocmd!
	" autocmd BufRead *otes/*.md normal yoz
	" autocmd BufRead /tmp/tmp*.txt normal yoz
augroup END

" writing dairy
augroup notable
	autocmd!
	autocmd BufWritePre *otes/*.md 1,7s/\v^modified:\ "\zs.*\ze"$/\=system('date -Is | head -c -1')
	autocmd BufWritePost  *otes/*.md normal ``
augroup END

augroup spellang
	autocmd!
	" autocmd FileType markdown setl spelllang+=cjk
	autocmd FileType mail,markdown setl spelllang=fr,en_us
augroup END

autocmd CompleteDone * pclose


" custom mapping
nnoremap <c-t> :vsplit <bar> terminal<cr>i
nnoremap <X1Mouse> <C-O>
nnoremap <X2Mouse> <C-I>
nnoremap <F5> :UndotreeToggle<CR>

" use <Shift> key to select; see https://stackoverflow.com/a/4608387/7870953
set mouse=a
set showcmd
set inccommand=split
set scrolloff=5
set undodir=/var/tmp/vim
set backupdir=/var/tmp/vim
set undofile
augroup rmundo
	autocmd!
	autocmd VimEnter /tmp/* set noundofile
augroup END

set spelllang=en_us
set conceallevel=2
set concealcursor=nc
hi Conceal NONE
hi Comment cterm=italic ctermfg=gray
hi Pmenu ctermbg=NONE ctermfg=white
hi PmenuSel ctermfg=yellow

set hidden
set autowrite
set foldmethod=syntax
set foldexpr=nvim_treesitter#foldexpr()
set fillchars=fold:\ ,
set modeline
set autochdir
set tabstop=4
set shiftwidth=0

" completion
set omnifunc=syntaxcomplete#Complete

let g:vimsyn_noerror=1
if system('whoami') =~ 'jing'
	" file locate $HOME/.config/nvim/lua/vim-init.lua
	lua require('vim-init')
endif
