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
function clone_github {
    if [ -d ~/.vim/bundle/$2 ]; then
        rm -rf ~/.vim/bundle/$2
    fi
    git clone --depth=1 $1 ~/.vim/bundle/$2
    rm -rf ~/.vim/bindle/$2/.git
}
clone_github https://github.com/sukima/xmledit.git xmledit
clone_github https://github.com/othree/html5.vim html5
clone_github https://github.com/hail2u/vim-css3-syntax.git css3

# Extra support for css3 inside of html files
if [ ! -d ~/.vim/after/syntax ]; then
    mkdir -p ~/.vim/after/syntax
fi
cat > ~/.vim/after/syntax/html.vim <<EOF
syn include @htmlCss syntax/css/html5-elements.vim
syn include @htmlCss syntax/css/css3-animations.vim
syn include @htmlCss syntax/css/css3-background.vim
syn include @htmlCss syntax/css/css3-box.vim
syn include @htmlCss syntax/css/css3-break.vim
syn include @htmlCss syntax/css/css3-colors.vim
syn include @htmlCss syntax/css/css3-content.vim
syn include @htmlCss syntax/css/css3-exclusions.vim
syn include @htmlCss syntax/css/css3-flexbox.vim
syn include @htmlCss syntax/css/css3-gcpm.vim
syn include @htmlCss syntax/css/css3-grid-layout.vim
syn include @htmlCss syntax/css/css3-hyperlinks.vim
syn include @htmlCss syntax/css/css3-images.vim
syn include @htmlCss syntax/css/css3-layout.vim
syn include @htmlCss syntax/css/css3-linebox.vim
syn include @htmlCss syntax/css/css3-lists.vim
syn include @htmlCss syntax/css/css3-marquee.vim
syn include @htmlCss syntax/css/css3-mediaqueries.vim
syn include @htmlCss syntax/css/css3-multicol.vim
syn include @htmlCss syntax/css/css3-preslev.vim
syn include @htmlCss syntax/css/css3-regions.vim
syn include @htmlCss syntax/css/css3-ruby.vim
syn include @htmlCss syntax/css/css3-selectors.vim
syn include @htmlCss syntax/css/css3-text.vim
syn include @htmlCss syntax/css/css3-transforms.vim
syn include @htmlCss syntax/css/css3-transitions.vim
syn include @htmlCss syntax/css/css3-ui.vim
syn include @htmlCss syntax/css/css3-values.vim
syn include @htmlCss syntax/css/css3-writing-modes.vim
EOF

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

