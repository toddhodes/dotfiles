#!/bin/zsh

autoload -Uz add-zsh-hook

# rake autocompletion from:
# http://weblog.rubyonrails.org/2006/3/9/fast-rake-task-completion-for-zsh
_rake_does_task_list_need_generating () {
  if [ ! -f .rake_tasks ]; then return 0;
  else
    accurate=$(stat -c%Y .rake_tasks)
    changed=$(stat -c%Y Rakefile)
    return $(expr $accurate '>=' $changed)
  fi
}

_rake () {
  if [ -f Rakefile ]; then
    if _rake_does_task_list_need_generating; then
      rake --silent --tasks | cut -d' ' -f2 2>/dev/null >.rake_tasks
    fi
    compadd `cat .rake_tasks`
  fi
}

# A simple zsh-based bookmarks system (kinda)
name-dir() {
  eval "hash -d ${1}=$(pwd)"
  echo "hash -d ${1}=$(pwd)" >> ${ZHOME}/named_dirs
  echo "~${1}"
}

_force_rehash() {
  (( CURRENT == 1 )) && rehash
  return 1 # Because we didn't really complete anything
}

# Based off http://gist.github.com/172292. Idea by @defunkt
# gist it! http://gist.github.com/172323 (zsh fork)
function ruby_or_irb() {
    if [[ "$1" == "" ]]; then
        command irb -f -I$XDG_CONFIG_DIR/irb -r irb_conf
    else
        command ruby $@
    fi
}
alias ruby=ruby_or_irb

function detach() {
    # Create the directory where we store the sockets, if it doesn't already
    # exist
    if [[ ! -d "$XDG_CACHE_HOME/dtach/" ]] ; then
        mkdir -p "$XDG_CACHE_HOME/dtach/"
    fi

    # From `dtach --help`:
    #     -A: Attach to the specified socket, or create it if it
    #         does not exist, running the specified command.
    dtach -A "$XDG_CACHE_HOME/dtach/$1.socket" -z -e "" $@
}

function smart_cd () {
  if [[ -f $1 ]] ; then
    [[ ! -e ${1:h} ]] && return 1
    builtin cd ${1:h}
  else
    builtin cd ${1}
  fi
}

function cd () {
  local approx1 ; approx1=()
  local approx2 ; approx2=()
  # No parameters, or the first one begins with a '+' or '-'
  if (( ${#*} == 0 )) || [[ ${1} = [+-]* ]] ; then
    # Are we in a VCS dir? (git only, relies on vcs_info) + no parameters?
    if [[ -n $vcs_info_msg_0_ ]] && (( ${#*} == 0 )); then
      builtin cd $(git rev-parse --show-toplevel)
    else
      builtin cd "$@"
    fi
  elif (( ${#*} == 1 )) ; then
    approx1=( (#a1)${1}(N) )
    approx2=( (#a2)${1}(N) )
    if [[ -e ${1} ]] ; then
      smart_cd ${1}
    elif [[ ${#approx1} -eq 1 ]] ; then
      smart_cd ${approx1[1]}
    elif [[ ${#approx2} -eq 1 ]] ; then
      smart_cd ${approx2[1]}
    else
      print couldn\'t correct ${1}
    fi
  elif (( ${#*} == 2 )) ; then
    builtin cd $1 $2
  else
    print cd: too many arguments
  fi
}

extract_archive () {
    local lower full_path target_dir
    lower=${(L)1} # Used for matching
    full_path=$(readlink -f $1) # The real path, expanded & absolute
    target_dir=$(echo $1 | sed 's/(\.tar|\.zip)?\.[^.]*$//') # new directory name
    md $target_dir # mkdir && cd combo
    case "$lower" in
        *.tar.gz) tar xzf "$full_path" ;;
        *.tgz) tar xzf "$full_path" ;;
        *.gz) gunzip "$full_path" ;;
        *.tar.bz2) tar xjf "$full_path" ;;
        *.tbz2) tar xjf "$full_path" ;;
        *.bz2) bunzip2 "$full_path" ;;
        *.tar) tar xf "$full_path" ;;
        *.rar) unrar e "$full_path" ;;
        *.zip) unzip "$full_path" ;;
        *.z) uncompress "$full_path" ;;
        *.7z) 7z x "$full_path" ;;
        *.xz) xz -d "$full_path" ;;
        *.lzma) unlzma -vk "$full_path" ;;
        *.lha) lha e "$full_path" ;;
        *.rpm) rpm2cpio "$full_path" | cpio -idmv ;;
        *.deb) ar p "$full_path" data.tar.gz | tar zx ;;
        *) print "Unknown archive type: $1" ; return 1 ;;
    esac
    # Change in to the newly created directory, and
    # list the directory contents, if there is one.
    current_dirs=( *(N/) )
    if [[ ${#current_dirs} = 1 ]]; then
        cd $current_dirs[1]
        ls
    fi
}

TRAPINT() {
        zle && [[ $HISTNO -eq $HISTCMD ]] && print -sr -- "$PREBUFFER$BUFFER"
        return $1
}

# Give us a root shell, or run the command with sudo.
# Expands command aliases first (cool!)
smart_sudo () {
    sudo_opts=""
    if [ ! -z "$SUDO_ASKPASS" ]; then
        sudo_opts="-A"
    fi
    if [[ -n $1 ]]; then
        #test if the first parameter is a alias
        if [[ -n $aliases[$1] ]]; then
            #if so, substitute the real command
            sudo $sudo_opts ${=aliases[$1]} $argv[2,-1]
        elif [[ "$1" = "vim" ]] ; then
            # sudo vim -> sudoedit
            sudoedit $sudo_opts $argv[2,-1]
        else
            #else just run sudo as is
            sudo $sudo_opts $argv
        fi
    else
        #if no parameters were given, then assume we want a root shell
        sudo $sudo_opts -s
    fi
}

# colorize stderr
color_err () {
    ## sysread & syswrite are part of zsh/system
    while sysread 'std_err'
    do
      syswrite -o 2 -- "${fg_bold[red]}${std_err}${terminfo[sgr0]}"
    done
}
# Automatically red-ify all stderr output
#exec 2> >( color_err )

function nicename() {
  for i in "$@" ; do
    j=$(echo "$i" | tr [[:upper:]] [[:lower:]] | tr ' ' _) && mv "$i" "$j"
  done
}

function errors() {
  # this monster is an awesome regular expression, yeah? Finds lot of errors in
  # a bunch of log formats!
  regexp='.*(missing|error|fail|\s(not|no .+) found|(no |not |in)valid|fatal|conflict|problem|critical|corrupt|warning|wrong|illegal|segfault|\sfault|caused|\sunable|\(EE\)|\(WW\))'

  # Default case: No parameters passed, so search all of /var/log
  log_path="/var/log"
  if [ -n "$1" ] ; then
    # If the parameter is a file, search only that one
    if [ -f "$1" ] ; then
      log_path="$1"
      smart_sudo find $log_path -type f -regex '[^0-9]+$' -exec grep -Eni $regexp {} \+ | $PAGER
    else
      echo $regexp
      return 0;
    fi
  fi
}

function cawk {
    first="awk '{print "
    last=" \"\"}'"
    cmd="${first}$(echo "$@" | sed "s:[0-9]*:\$&,:g")${last}"
    eval $cmd
}

for i in ${DOTSDIR}/zsh/functions/*(*) ; do
  alias "${i:t}"="unalias '${i:t}'; autoload -U '${i:t}'; ${i:t}"
done

autoload colors zsh/terminfo

df() {
  # Is dfc installed & did I not pass any arguments to df? Also, make sure that
  # there are >85 columns. Less than/equal to that, things go wonky. 85 is the
  # width of a terminal when it is 50% of the screen.
  if [ -n "${commands[dfc]}" -a $# -eq 0 -a $COLUMNS -gt 85 ]; then
    # Add 64 so that sed won't delete the ANSI color codes. Why 64? Just guessed
    # 50-60, then kept incrementing until the lines got too long. 64 works
    # perfectly.
    command dfc -a -T -w -W -o -i -f -c always | sed "s/^\(.\{,$(($COLUMNS+64))\}\).*/\\1/"
  else
    # Just run df like normal, passing along any parameters
    command df $@
  fi
}

# just type '...' to get '../..'
rationalise-dot() {
  local MATCH
  if [[ $LBUFFER =~ '(^|/| |	|'$'\n''|\||;|&)\.\.$' ]]; then
    LBUFFER+=/
    zle self-insert
    zle self-insert
  else
    zle self-insert
  fi
}
zle -N rationalise-dot

# A smarter(ish) g alias: By default, 'g' alone will show the status. 'g blah'
# still works.
function g {
  if [[ $# > 0 ]]; then
    if [[ "$@" = "st" ]]; then
      echo "\e[33mstop doing that! just use 'g'"
    else
      git "$@"
    fi
  else
    git status --short --branch
  fi
}

function _ls-on-cd() {
  emulate -L zsh
  ls
}
add-zsh-hook chpwd _ls-on-cd

# Uses xdotool & the environment variable $WINDOWID to check if the current
# window is focused in X11. Also requires $DISPLAY to be set (used as a signal
# that X11 is indeed running).
#
# Returns 1 or 0, so you can easily to __is-my-window-focused && notify-send or
# similar.
function __is-my-window-focused() {
  [[ -n "${WINDOWID}" ]] || return 1
  [[ -n "${DISPLAY}" ]] || return 1
  [[ ${$(xprop -root -notype -format _NET_ACTIVE_WINDOW 32i ' $0\n' _NET_ACTIVE_WINDOW):1} = $WINDOWID ]]
}

# Prints the current directory hierarchy, excluding the present directory's
# name. e.g. If you are in '/opt/vagrant/bin', this prints out '/opt/vagrant/'.
# (Note the trailing slash!) This is useful, for instance, when you want to
# color the current directory name differently than the rest of the path.
_current_dir_path() {
  if [[ $PWD = '/' ]]; then
    echo ""
  elif [[ $PWD = $HOME ]]; then
    echo ""
  else
    echo "${$(print -P %~)%/*}/"
  fi
}

# Get the environment variables for a particular process ID.
pidenv() {
  local env_path="/proc/${1:-self}/environ"
  if [[ ! -f $env_path ]] ; then
    echo "pidenv: No such process id ${1:-self}"
    return 2
  fi

  # I don't think this qualifies for the "Useless Use of Cat" award since I'm
  # trying to read a file that the current user may or may not have permission
  # to read.
  local cat_cmd
  if [[ -r $env_path ]] ; then
    cat_cmd="cat"
  else
    cat_cmd="sudo cat"
  fi

  eval "${cat_cmd} ${env_path} | xargs -n 1 -0 | sort"
}

# Get the time the process was started. (This works by investigating the
# timestamp for the per-process directory in /proc.)
pidstarted() {
  local pid_path="/proc/${1:-self}"
  if [[ ! -d $pid_path ]] ; then
    echo "pidstarted: No such process id ${1:-self}"
    return 2
  fi

  date --date="@$(stat -c '%Z' ${pid_path})" +'%d %b %Y, %H:%M'
}
