########################
# Global aliases
alias -g   H='|head'
alias -g   L='|less'
alias -g NUL='&>/dev/null'
alias -g   T='|tail'
alias -g   G='|grep'
alias -g   N='&>/dev/null'
alias -g   S='|sort'
alias -g  TO='2>&1 3>&1' # '&>&1' returns a parse error
alias -g   U='|uniq'

########################
# Listing aliases
alias      ls='ls --color=auto -F'
alias     lsa='ls -A'                      # only show dot-files
alias     lsw='ls -d *(R,W,X.^ND/)'        # world-{readable,writable,executable} files
alias     lsd='ls -d *(/)'                 # only show directories
alias     lse='ls -d *(/^F)'               # only show empty directories
alias     lss='ls *(s,S,t)'                # only files with setgid/setuid/sticky
alias     lsl='ls *(@)'                    # only symlinks
alias     lsx='ls *(*)'                    # only executables
alias   lsnew="ls -rl *(D.om[1,10])"       # display the newest files
alias   lsold="ls -rtlh *(D.om[1,10])"     # display the oldest files
alias   lsbig="ls -flh *(.OL[1,10])"       # display the biggest files
alias lssmall="ls -Srl *(.oL[1,10])"       # display the smallest files
# `ll' series of listing aliases: More detailed, and more verbose.
alias      ll='ls -lAh'
alias     llw='ll -d *(R,W,X.^ND/)'        # world-{readable,writable,executable} files
alias     lld='ll -d *(/)'                 # only show directories
alias     lle='ll -d *(/^F)'               # only show empty directories
alias     lls='ll *(s,S,t)'                # only files with setgid/setuid/sticky
alias     lll='ll *(@)'                    # only symlinks
alias     llx='ll *(*)'                    # only executables


########################
# Default aliases
#
# Some coreutils I use every day just seem to have silly defaults. Like mkdir,
# example. Why not support 'this/does/not/exist' and automatically make the
# parent directories?
alias mkdir='mkdir -p'
alias cp='cp -Ri'
alias rm='rm -rv --one-file-system --no-preserve-root'
alias mv='mv -i'
alias grep="grep $GREP_DEFAULTS" # Only use my preferences in the parent process

########################
# Convenience aliases
alias nhclean='rm ./**/nohup.out'
alias swpclean='rm $(find G "\/\..*\.swp$")'
alias yrm='yes | rm -rvf'
alias startxl="startx &>/tmp/startx.log"

alias PS="ps wwaux"
alias psg="PS G -v grep G"

alias makepkg="makepkg -s"

alias addme='s gpasswd -a colin'

alias edit="${EDITOR}"
alias s=`whence -p sudo`

alias git-branch-name="git branch | sed '/^\*/!d; s/^\* //'"
#alias vinny='vim --cmd "let g:vimMode = \"notes\""'

alias vim2html='vim -c "let html_number_lines = 1" -c "let use_xhtml =1 " -c "let html_use_css = 1" -c "TOhtml" -c "set nu" -c "syntax on" -c "wq" -c "q" &>/dev/null'

alias mailcount="find $MAILDIR | grep -P new\/.? | sed 's@.*mail/\(.*\)/new.*@\1@' | awk '{a[\$1]++}END{for(i in a){print a[i] \" \" i}}' | sort -rn"
alias wtf="wtf -f $HOME/.config/acronyms.wtf"

alias ssh-me="ssh me -t 'screen -R'"

########################
# Web & 'catw'
#
# catw is a simple
if [ -z "$(whence curl)" ] ; then
    alias catw="wget -qO - "
else
    alias catw="curl -s "
fi
alias meme="catw meme.boxofjunk.ws/moar.txt?lines=1"
alias myip="catw http://icanhazip.com"


########################
# 'special' character aliases.
alias --      -="cd - &>/dev/null"  # Go to the last directory
alias         .='cd .'              # Have '.' match behaviour of .[.]+
alias -g    ...='cd ../..'
alias -g   ....='cd ../../..'
alias -g  .....='cd ../../../..'
alias -g ......='cd ../../../../..'

alias maxup="echo \$(uprecords -a | head -n3 | tail -n1 | sed s/\-\>// | awk '{ print \$2, \$3, \$4 }')" # requires uptimed

alias portstat="s netstat -tunelp"

alias gh-pages='git symbolic-ref HEAD refs/heads/gh-pages && rm .git/index && git clean -fdx'

if [ ! -z "${commands[hub]}" -a ! -z "${commands[git]}"  ]; then
    eval `hub alias -s zsh`
fi

alias  m="$EDITOR"
alias  g="git"

alias s=smart_sudo
alias extr=extract_archive
# sudo the previous command
alias ss="s \$(fc -l \$[ \$(print -P '%\!') - 1 ] | cut -d' ' -f3-)"

alias which='alias | /usr/bin/which --tty-only --read-alias --show-dot --show-tilde'
alias wc='wc -l'
alias gem="gem --config-file=${XDG_CONFIG_HOME}/gemrc"
alias irssi="irssi --config=${XDG_CONFIG_HOME}/irssi/config --home=${XDG_CONFIG_HOME}/irssi"
alias mutt="mutt -F ${XDG_CONFIG_HOME}/mutt/muttrc"
# Given a list of DNS servers in /etc/resolv.conf, ping each one.
alias ping-dns='echo Nameservers: $(grep "nameserver" /etc/resolv.conf | tr -d "namesrv\n"); for dserver in $(grep "nameserver" /etc/resolv.conf | cut -d" " -f2); do echo -n "${dserver} "; ping -q -c4 $dserver | grep "time"; done | column -t)'
alias xf=extract_archive
alias list-dbus="qdbus | sed '/^:/d;s/ //' | sort"
