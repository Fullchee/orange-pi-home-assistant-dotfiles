# Files


alias cat=batcat
alias -s {js,json,env,md,html,css,toml}=cat

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

alias la="eza --icons --grid --all"
alias ll='eza -la --git --icons'
alias searchtree='eza --tree --icons --git-ignore | fzf'

function ls() {
  # 1. Define the default flags as a Zsh **array** for correct expansion.
  local default_flags=(--git --icons --grid --git-ignore)

  # 2. Check if any of the exclusion flags are present in the arguments provided to 'ls'.
  if [[ " $@ " =~ " -a " || " $@ " =~ " --all " || " $@ " =~ " --no-git " ]]; then
    # 3. If an exclusion flag is found, remove '--git-ignore' from the default_flags array.
    # The '=${arrayname/(pattern)/}' syntax is a Zsh array removal/substitution.
    default_flags=(${default_flags[@]/:#--git-ignore/})
  fi

  # 4. Execute 'eza' using "${default_flags[@]}" to expand the array
  # correctly into separate, quoted arguments, followed by the user's arguments ($@).
  eza "${default_flags[@]}" "$@"
}

# Arguments:
#   Depth (int) (optional, default=2)
# Usage:
#	tree . 1
# 	tree folder_name 2
tree() {
	eza --tree --icons --git-ignore -L "${2:-2}" "${1:-.}"
}

## suffix aliases
# https://www.stefanjudis.com/today-i-learned/suffix-aliases-in-zsh/
alias -s {js,json,env,gitignore,md,html,css,toml}=cat

alias ...="cd ../.."
alias ....="cd ../../.."

#### File and folder helpers START

mkcd() {
  mkdir "$1"
  cd "$1"
}

function diffdir() {
	diff -r $1 $2 | grep $1 | awk '{print $4}'
}

function t() {
	# Defaults to 3 levels deep, do more with `t 5` or `t 1`
  	# pass additional args after
	tree -I '.git|node_modules|.DS_Store' --dirsfirst -L ${1:-3} -aC $2
}

# asdf/fileName.ext => fileName
function extract-filename() {
	fullfile="$1"
	filename=$(basename "$fullfile")  # asdf/fieleName.ext => fileName.ext
	echo "${filename%.*}"  # fileName.ext => fileName
}
