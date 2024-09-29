" Enable line numbers and relative line numbers for better navigation
set number               " Show absolute line numbers
set relativenumber       " Show relative line numbers

" Enable syntax highlighting and file type detection
syntax on                " Enable syntax highlighting
filetype on               " Enable file type detection
filetype plugin on       " Enable file type-specific plugins
filetype indent on       " Enable file type-specific indentation

" Set indentation preferences
set tabstop=4            " Number of spaces per tab
set shiftwidth=4        " Number of spaces for indentation
set expandtab            " Convert tabs to spaces
set smartindent          " Automatically insert indentations

" Show whitespace characters (for debugging indentation issues)
set list                  " Show whitespace characters like tabs and trailing spaces
set listchars=tab:»·,trail:·  " Customize the appearance of whitespace characters

" Enable search highlighting and incremental search
set hlsearch              " Highlight search results
set incsearch             " Show search matches as you type
set ignorecase            " Ignore case in searches
set smartcase             " Override ignorecase if search contains uppercase

" Enable mouse support for easier navigation
set mouse=a              " Enable mouse support in all modes

" Configure clipboard to use the system clipboard
set clipboard=unnamedplus " Use the system clipboard for copy and paste

" Enable line wrapping and configure display settings
set wrap                 " Enable line wrapping
set linebreak            " Break lines at convenient points
set showbreak=↪           " Show a symbol when a line is wrapped

" Set up key mappings for common tasks
nnoremap <C-S> :w<CR>    " Save the current file with Ctrl+S
nnoremap <C-q> :q<CR>    " Quit Vim with Ctrl+Q

" Configure split windows for better workspace management
set splitbelow           " Open horizontal splits below the current window
set splitright           " Open vertical splits to the right of the current window

" Enable auto-indentation for new lines
set autoindent           " Copy the indentation of the current line to new lines
set smartindent          " Automatically adjust indentation

" Enable status line with useful information
set laststatus=2         " Always show the status line
set statusline=%f\ %y\ %m\ %r\ %=%-14.(%l,%c%V%)\ %P " Customize status line

" Set a color scheme and enable 256-color support
colorscheme desert       " Set the color scheme (change to your preference)
set t_Co=256             " Enable 256-color support

" Configure undo options
set undofile             " Keep an undo history file
set undodir=~/.vim/undo  " Directory for undo files
set undolevels=1000      " Number of undo levels

" Autocommands for common tasks
autocmd BufWritePre *.py execute ':Black'   " Auto-format Python files with Black before saving

" Additional custom commands
command! W w !sudo tee %  " Save the file with sudo permissions

" Map leader key for custom shortcuts
let mapleader=","          " Set comma as the leader key
nnoremap <Leader>ff :Files<CR>  " Find files with fzf
nnoremap <Leader>tt :NERDTreeToggle<CR> " Toggle NERDTree file explorer