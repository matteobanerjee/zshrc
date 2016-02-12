export JAVA_HOME=$(/usr/libexec/java_home -v 1.8)
export EDITOR=emacs

# Use menu completion after second tab key press
setopt auto_menu

# If completion ends in '/' and next char is slash/word separator, remove '/'
setopt auto_remove_slash

# Append command to history file once executed
# (so we don't lose history if disconnected)
setopt inc_append_history

# Ignore duplicate entries
setopt hist_ignore_all_dups

##########
# COLORS #
##########
# Make working with color escape codes easier
init_colors() {
  local prefix=''
  local suffix=''
  local shell=zsh

  # Stops zsh from counting escape sequences as characters.
  # This prevents the PS1 prompt from counting
  prefix='%{'
  suffix='%}'

  # Escape sequence for prompts
  PRESET="$prefix[00m$suffix"
  PBOLD="$prefix[01m$suffix"
  PITALIC="$prefix[03m$suffix"
  PUNDERLINE="$prefix[04m$suffix"
  PBLINK="$prefix[05m$suffix"
  PREVERSE="$prefix[07m$suffix"
  PSTARTLINE=""

  RESET="[00m"
  BOLD="[01m"
  ITALIC="[03m"
  UNDERLINE="[04m"
  BLINK="[05m"
  REVERSE="[07m"


  typeset -Ag FG BG PFG PBG


  for color in {0..255}; do
    FG[$color]="[38;5;${color}m"
    BG[$color]="[48;5;${color}m"
    PFG[$color]="$prefix[38;5;${color}m$suffix"
    PBG[$color]="$prefix[48;5;${color}m$suffix"
  done

  colors() {
    for code in {0..255}; do
      printf "${reset}${FG[$code]}%03s: The quick brown fox jumped over the lazy dog\n" "$code"
    done
  }
  alias colors=colors
}

init_colors

#######
# GIT #
#######

alias g=git

active_git_branch () {
  local ref=`git symbolic-ref HEAD 2> /dev/null`
  echo "${ref#refs/heads/}"
}

git_branch_ahead () {
  local branch=`active_git_branch`
  `git log origin/$branch..HEAD 2> /dev/null | grep '^commit' &> /dev/null` \
    && echo '➨'
}

##########
# PROMPT #
##########

# % escapes expanded in prompts
setopt prompt_percent
# Allow $ expansion in prompts
setopt prompt_subst

# Runs after a command is executed (or interrupted),
# before the prompt is rendered for the next command.
precmd() {
  # Display exit code if non-zero
  local ret=$?
  if [ ! $ret -eq 0 ]; then
    echo -e "\033[0;31m→ exit status: $ret\033[0m" >&2
  fi

  # Update terminal title bar if one is available
  if [[ "$TERM" =~ xterm* ]]; then
    echo -en "\033]0;$USER@$(hostname):$(__prompt_curdir)\007"
  fi
}

# Prompt escape variables differ between shells, so use functions instead
__prompt_curdir() {
  local dir="$PWD"
  echo "${dir/#$HOME/~}"
}

# Display the currently git branch and status if we're in a git repository
__git_prompt() {
  local branch=`active_git_branch`
  if [ ! -z "$branch" ]; then
    echo " `git_branch_ahead`$branch"
  else
    echo ""
  fi
}


# Main prompt line
PS1="${PSTARTLINE}${PRESET}${PFG[240]}\$USER${PRESET}"
PS1="${PS1}${PFG[234]}:${PFG[136]}\$(__prompt_curdir)${PRESET}"
PS1="${PS1}${PFG[64]}\$(__git_prompt)${PRESET}"
PS1="${PS1}${PFG[33]} ⨠ ${PRESET}"

# Prompt to display at beginning of next line when command spans multiple lines
PS2="${PFG[33]}↳${PRESET} "

# Debug line prefix
PS4="→ `[ "$0" != -bash ] && echo ${FG[64]}$0:${FG[33]}$LINENO || echo` ${RESET}"

