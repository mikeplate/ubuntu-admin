#!/bin/bash

# Ensure directories exist
vim_dirs=(autoload syntax ftdetect bundle)
for vimdir in "${vim_dirs[@]}"; do
    if [ ! -d ~/.vim/$vimdir ]; then
        mkdir -p ~/.vim/$vimdir
    fi
done

# ASP.NET Syntax
wget http://www.vim.org/scripts/download_script.php?src_id=2906 -O ~/.vim/syntax/aspnet.vim
echo "au BufRead,BufNewFile *.aspx,*.asmx,*.ascx set filetype=aspnet" > ~/.vim/ftdetect/aspnet.vim

# Ruby Syntax
wget https://raw.github.com/vim-ruby/vim-ruby/master/syntax/ruby.vim -O ~/.vim/syntax/ruby.vim
echo "au BufRead,BufNewFile *.rb,*.ru,Rakefile,rakefile set filetype=ruby" > ~/.vim/ftdetect/ruby.vim

# Nginx Config Syntax
wget https://github.com/evanmiller/nginx-vim-syntax/raw/master/syntax/nginx.vim -O ~/.vim/syntax/nginx.vim
echo "au BufRead,BufNewFile *.conf set filetype=nginx" > ~/.vim/ftdetect/nginx.vim

# Pathogen
wget https://raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim -O ~/.vim/autoload/pathogen.vim

# Github projects
git clone --depth=1 https://github.com/sukima/xmledit.git ~/.vim/bundle/xmledit
rm -rf ~/.vim/bindle/xmledit/.git

# Ensure autostart script statements
vimrc_commands=(
    "colorscheme desert"
    "set tabstop=4 softtabstop=4 shiftwidth=4 expandtab autoindent smartindent"
    "call pathogen#infect()"
    "filetype plugin indent on"
)
touch ~/.vimrc
for cmd in "${vimrc_commands[@]}"; do
    grep -q "$cmd" ~/.vimrc
    if [ $? -ne 0 ]; then
        echo "$cmd" >> ~/.vimrc
    fi
done

