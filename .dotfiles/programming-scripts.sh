# Table of contents
# General
# Android
# Databases
# Networking

## -----
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/fullcheezhang/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions
## -------- General --------
alias sz="source ~/.zshrc"
alias tldrf='tldr --list | fzf --preview "tldr {1} --color=always" --preview-window=right,70% | xargs tldr'

## -------- General end  --------

alias ip="echo Your ip is; dig +short myip.opendns.com @resolver1.opendns.com;"

killport() {
    if [ -z "$1" ] ; then
        echo 'Usage: killport <portnumber'
        return
    fi
    kill $(lsof -t -i:"$1")
}

# write current command location to `.zsh_history_ext` whenever a command is ran
# `.zsh_history_ext` is used in `lc` command
function zshaddhistory() {
  # ignore empty commands
  if [[ $1 == $'\n' ]]; then return; fi

  # ignore specific commands
  local COMMANDS_TO_IGNORE=( last ls ll cd j git gss gap lc ggpush ggpull);
  for i in "${COMMANDS_TO_IGNORE[@]}"
  do
    # return if the run commands starts with the ignored commands
    if [[ $1 == "$i"* ]]; then
      return;
    fi
  done

  echo "${1%%$'\n'}${LC_DELIMITER_START}${PWD}${LC_DELIMITER_END}" >> ~/.lc_history
}

# `lc`:  last command
function last() {
  SELECTED_COMMAND=$(grep -a --color=never "${PWD}${LC_DELIMITER_END}" ~/.lc_history | cut -f1 -d "${LC_DELIMITER_START}" | tail -r | fzf);

  # handle case of selecting no command via fzf
  if [[ ${#SELECTED_COMMAND} -gt 0 ]]; then
    echo "Running '$SELECTED_COMMAND'..."
    echo "**************************"
    eval " $SELECTED_COMMAND";
  fi
}

## Python
export PATH="$HOME/.pyenv/bin:$PATH"
export PYTHONSTARTUP=$HOME/.dotfiles/repl_startup.py
alias py=python
eval "$(pyenv init --path)"
PIP_REQUIRE_VIRTUALENV=true
alias ptpy=ptpython

# uv?
if [ -f "$HOME/.local/bin/env" ]; then
  . "$HOME/.local/bin/env"
fi
eval "$(uv generate-shell-completion zsh)"

venv() {
  # no arg given -> try venv and .venv
  if [[ -z "$1" ]]; then
    if [[ -f "venv/bin/activate" ]]; then
      source venv/bin/activate
      return
    elif [[ -f ".venv/bin/activate" ]]; then
      source .venv/bin/activate
      return
    elif [[ -f "../venv/bin/activate" ]]; then
      source ../venv/bin/activate
      return
    elif [[ -f "../.venv/bin/activate" ]]; then
      source ../.venv/bin/activate
      return
    else
      echo "Please provide a path to your venv. Didn't find a venv or .venv"
      return 1
    fi
  fi

  if [[ -f "$1/venv/bin/activate" ]]; then
    source "$1/venv/bin/activate"
  elif [[ -f "$1/.venv/bin/activate" ]]; then
    source "$1.venv/bin/activate"
  elif [[ -f "$1/bin/activate" ]]; then
    source "$1/bin/activate"
  else
    echo "'$1/bin/activate' does not exist."
    return 1
  fi
}

## Python end
