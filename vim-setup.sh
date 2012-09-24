#!/bin/bash

# Ensure directories exist
if [ ! -d ~/.vim/syntax ]; then
    mkdir -p ~/.vim/syntax
fi
if [ ! -d ~/.vim/ftdetect ]; then
    mkdir -p ~/.vim/ftdetect
fi

# ASP.NET Syntax
wget http://www.vim.org/scripts/download_script.php?src_id=2906 -O ~/.vim/syntax/aspnet.vim
echo "au BufRead,BufNewFile *.aspx,*.asmx,*.ascx set filetype=aspnet" > ~/.vim/ftdetect/aspnet.vim

# Ruby Syntax
wget https://raw.github.com/vim-ruby/vim-ruby/master/syntax/ruby.vim -O ~/.vim/syntax/ruby.vim
echo "au BufRead,BufNewFile *.rb,*.ru,Rakefile,rakefile set filetype=ruby" > ~/.vim/ftdetect/ruby.vim

# Ensure autostart script statements
vimrc_commands=(
    "colorscheme desert"
    "set tabstop=4 softtabstop=4 shiftwidth=4 expandtab autoindent smartindent"
)
for cmd in "${vimrc_commands[@]}"; do
    grep -qE "^$cmd\$" ~/.vimrc
    if [ $? -ne 0 ]; then
        echo "$cmd" >> ~/.vimrc
    fi
done

