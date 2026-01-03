export EDITOR=/usr/bin/vim
export VISUAL=/usr/bin/vim

# --- CONFIG
# use 'config' instead of 'git' to manage this git repo, lose all git auto-complete commands :(
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME' $@
alias dotfiles='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME' $@
alias save-crontab='sudo crontab -l >| ~/.backup-crontab.sh'
alias pull='git stash && git pull && git stash pop'
alias copy-tech-notes="~/learning/notes/copy-to-tech-notes.sh"

alias it="git"  # common typo
# alias gc="git commit -a --no-verify -m"
alias gc="git commit -a -m"
alias gs="git st"
alias fetchmerge="git fetch && git merge origin/main --no-edit"
alias fm=fetchmerge

alias viewpr="gh pr view --web"


function git-clone-personal() {
    local REPO_URL="$1"
    # 1. Define the command once
    local SSH_CMD="ssh -i ~/.ssh/personal_id_ed25519 -o IdentitiesOnly=yes"

    # 2. Use the variable for the initial clone
    GIT_SSH_COMMAND="$SSH_CMD" git clone "$REPO_URL"

    if [ $? -eq 0 ]; then
        local REPO_DIR
        REPO_DIR=$(basename "$REPO_URL" .git)

        cd "$REPO_DIR" || return

        # 3. Use the variable again to persist the config
        git use-personal-ssh
        git config user.email "fullchee@gmail.com"

        echo "✅ Cloned '$REPO_DIR' using personal identity."
    else
        echo "❌ Clone failed."
    fi
}


prfiles() {
    PR_URL=$(gh pr view --json url --jq '.url')
    open "${PR_URL}/files"
}

switchpr() {
	GH_FORCE_TTY=100% gh pr list --assignee "fullchee" | tail -n +2 | fzf --ansi --preview 'GH_FORCE_TTY=100% gh pr view {1}' --preview-window down --header-lines 3 | awk '{print $1}' | xargs gh pr checkout
}

pulls() {
	GH_FORCE_TTY=100% gh pr list --assignee "fullchee" | tail -n +2 | fzf --ansi --preview 'GH_FORCE_TTY=100% gh pr view {1}' --preview-window down --header-lines 3 | awk '{print $1}' | xargs gh pr view --web
}

function configpush() {
	config add -u
	if [ -z "$1" ] ; then
		config commit -m "$(date)"
	else
  		config commit -m $1
	fi
	config pull
	config push
}
alias pushconfig="configpush"
alias dotfilespush="configpush"
alias pushdotfiles="configpush"

function pushnotes() {
	git -C ~/learning/notes add -A
	if [ -z "$1" ] ; then
		git -C ~/learning/notes commit -m "$(date)"
	else
  		git -C ~/learning/notes commit -m $1
	fi
	git -C ~/learning/notes pull;
	git -C ~/learning/notes push;
}

function rm_branch() {
	branch_name=`git rev-parse --abbrev-ref HEAD`;
	git stash;
	git checkout main;
	git branch -D $branch_name;
	git pull;
	git stash pop;
}

delete_current_branch() {
	branch_name=`git rev-parse --abbrev-ref HEAD`;
	git checkout main
	git branch -D $branch_name
}

function delete_remote_branch() {
	if read -q "choice?Delete remote branch? (Y/y)"; then
		branch_name=`git rev-parse --abbrev-ref HEAD`;
		git push origin --delete $branch_name;
	else
		echo "Not deleting remote branch"
		exit 1
	fi
}

function delete_remote_and_local_branch() {
	if read -q "choice?Delete remote branch? (Y/y)"; then
		branch_name=`git rev-parse --abbrev-ref HEAD`;
		git push origin --delete $branch_name;
		delete_current_branch
	else
		echo "Not deleting remote branch"
		exit 1
	fi
}


# Zsh function to interactively select and delete a local Git branch,
# with an option to delete the remote branch if it exists.
# Accepts:
# -f or --force: uses 'git branch -D' for forced local deletion.
# --current: deletes the currently checked-out branch.

doesnt-work-rm-branch() {
    local current_branch=$(git rev-parse --abbrev-ref HEAD)
    local selected_branch=""
    local delete_current=0
    local force_delete_local=0

    # --- Argument Parsing ---
    for arg in "$@"; do
        case $arg in
            -f|--force)
                force_delete_local=1
                shift # Remove flag from argument list
                ;;
            --current)
                delete_current=1
                shift # Remove flag from argument list
                ;;
        esac
    done

    # --- 1. Branch Selection Logic ---
    if [[ "$delete_current" -eq 1 ]]; then
        # Handle --current flag: Must switch branches first
        if git show-ref --quiet refs/heads/main; then
            git checkout main
        elif git show-ref --quiet refs/heads/master; then
            git checkout master
        else
            echo "🛑 Cannot delete the current branch **$current_branch**. Please switch to 'main' or 'master' first, or ensure one exists."
            return 1
        fi
        selected_branch="$current_branch"
        echo "Switched to branch: **$(git rev-parse --abbrev-ref HEAD)** before deleting **$selected_branch**."
    else
        # Prepare the list of branches to delete (excluding main/master)
        # Note: We still let the current branch appear in the list, but filter it out later.
        local branches_to_delete=$(git branch --list --format="%(refname:short)" | grep -v -E "^(main|master)$")

        if [ -z "$branches_to_delete" ]; then
            echo "🤔 No deletable branches found (excluding main/master)."
            return 1
        fi

        local force_status=""
        if [[ "$force_delete_local" -eq 1 ]]; then
            force_status="[MODE: FORCE DELETE (-f)]"
        fi

        # Define the header to display the current branch status
        local fzf_header="${force_status}\nCURRENT: $current_branch (run 'rm-branch --current' to delete it)\n\nSelect branch to delete:"

        # 2. Pipe to fzf for selection
        selected_branch=$(echo "$branches_to_delete" | fzf \
            --prompt="" \
            --header="$fzf_header" \
            --header-lines=3 \
            --height 40% \
            --border \
            # Prevent selection of current/main/master by filtering on 'enter'
            --bind "enter:unbind(enter)+execute-silent(grep -v \"^$current_branch$\" | grep -v \"^main$\" | grep -v \"^master$\" > /dev/tty)" \
            --expect=enter)

        if [ -z "$selected_branch" ]; then
            echo "❌ No branch selected. Exiting."
            return 0
        fi

        # Check if the user selected a forbidden branch (Main/Master is handled by grep -v above, but current branch needs a final check)
        if [[ "$selected_branch" == "$current_branch" ]]; then
            echo "🛑 You cannot select the current branch **$selected_branch** from the list. Use 'rm-branch --current' to delete it."
            return 1
        fi
    fi

    echo "Selected branch for deletion: **$selected_branch**"

    # TODO: exit if the selected branch is main or master
    # Explicit Safety Check for main/master (Redundant for fzf selection, but covers all paths)
    if [[ "$selected_branch" == "main" || "$selected_branch" == "master" ]]; then
        echo "🛑 Deleting the main or master branch is not allowed. Exiting."
        return 1
    fi

    # --- 2. Local Deletion ---
    # The command is executed by joining the variable and the branch name
	if [[ $force_delete_local -eq 1 ]]; then
		delete_branch_command="git branch -D $selected_branch"
	else
		delete_branch_command="git branch -d $selected_branch"
	fi

    if $delete_branch_command; then
        echo "✅ Locally deleted branch: **$selected_branch** (Command: $delete_branch_command)"
    else
        if [[ "$force_delete_local" -eq 0 ]]; then
            echo "🚨 Failed to delete local branch **$selected_branch**. It has unmerged changes. Rerun with '-f' to force deletion: 'rm-branch -f'."
        else
            echo "🚨 Even forced deletion failed for local branch **$selected_branch**. Command: *** $delete_branch_command ***"
        fi
        return 1
    fi

    # --- 3. Remote Deletion Check and Prompt ---

    # Check if 'origin' remote is configured
    if ! git remote show origin > /dev/null 2>&1; then
        echo "⚠️ No 'origin' remote found. Skipping remote deletion check."
        return 0
    fi

    # Check for remote branch existence
    if git show-ref --quiet "refs/remotes/origin/$selected_branch" || gh api repos/:owner/:repo/branches/"$selected_branch" > /dev/null 2>&1; then
        echo "🌍 Branch **$selected_branch** also exists on remote **origin**."

        # Ask to delete the remote branch and validate input
        local delete_remote_response=""
        while ! [[ "$delete_remote_response" =~ ^([Yy]|$)$ || "$delete_remote_response" =~ ^[Nn]$ ]]; do
            read -q "delete_remote_response?Do you want to delete the remote branch as well? ([Y]/n/Enter): "
            echo # Print a newline after the read -q
            if [[ -z "$delete_remote_response" || "$delete_remote_response" =~ ^[Yy]$ ]]; then
                # Delete the remote branch
                if git push origin --delete "$selected_branch"; then
                    echo "✅ Remotely deleted branch: **origin/$selected_branch**"
                else
                    echo "❌ Failed to delete remote branch **origin/$selected_branch**."
                fi
                break
            elif [[ "$delete_remote_response" =~ ^[Nn]$ ]]; then
                echo "🛑 Skipped remote branch deletion for **origin/$selected_branch**."
                break
            else
                echo "⚠️ Invalid input. Please enter 'y', 'n', or press 'Enter' (which defaults to 'yes')."
            fi
        done
    else
        echo "💡 Branch **$selected_branch** does not appear to exist on the remote **origin**."
    fi
}

createpr() {
	git stash;
	git switch -c $1;
	git empty-commit;  # see .gitconfig
	git push origin $1;
	git set-upstream;  # see .gitconfig

    BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)
    if [[ "$BRANCH_NAME" == "main" || "$BRANCH_NAME" == "master" || "$BRANCH_NAME" == "develop" ]]; then
        echo "Error: Cannot create a PR from branch '$BRANCH_NAME'. Please switch to a feature branch." >&2
        exit 1
    fi

    # 2. Extract TICKET_ID (e.g., DEV-4304)
    # This captures the first two components of the hyphenated string.
    TICKET_ID=$(echo "$BRANCH_NAME" | awk -F'-' '{print $1 "-" $2}')

    # 3. Extract RAW_DESCRIPTION (e.g., precommit)
    # This uses sed to remove the TICKET_ID and the following hyphen from the start.
    RAW_DESCRIPTION=$(echo "$BRANCH_NAME" | sed "s/^$TICKET_ID-//")

    # 4. Format the Description Text:
    # a. Replace hyphens with spaces (e.g., 'precommit-changes' -> 'precommit changes')
    SPACED_DESCRIPTION=$(echo "$RAW_DESCRIPTION" | tr '-' ' ')

    # b. Capitalize the first letter of the first word only (e.g., 'frontend feature flag dx' -> 'Frontend feature flag dx')
    # Use awk to capitalize first letter of first word while keeping the rest lowercase
    DESCRIPTION_TITLE=$(echo "$SPACED_DESCRIPTION" | awk '{$1=toupper(substr($1,1,1)) tolower(substr($1,2)); print}')

    # 5. Construct the FINAL PR TITLE
    PR_TITLE="[${TICKET_ID}] ${DESCRIPTION_TITLE}"

    # 6. Construct the PR BODY (The first line is the H1 title)
    PR_BODY="# ${PR_TITLE}

## Changes

- ${DESCRIPTION_TITLE}

## Review instructions

1.


## Checklist
- [ ] test coverage
    "

    gh pr create \
    --title "$PR_TITLE" \
    --body "$PR_BODY" \
    --assignee "@me" \
    --draft;

    git stash pop;
    gh pr view --web;
}

bumpversion() {
	npm version patch --no-git-tag-version;
	git add package.json package-lock.json;
	git commit -m "Bump version";
	git push;
}

push() {
    local no_verify=""
    local prefix="[skip ci] " # Default prefix includes the space
    local message=""

    for arg in "$@"; do
        case $arg in
            --no-verify)
                no_verify="--no-verify"
                ;;
            --ci)
                prefix="" # Remove prefix if --ci flag is present
                ;;
            *)
                # This builds the message even if multiple words are passed without quotes
                if [ -z "$message" ]; then
                    message="$arg"
                else
                    message="$message $arg"
                fi
                ;;
        esac
    done

    # Basic check to ensure a message exists
    if [ -z "$message" ]; then
        echo "Error: Commit message required."
        return 1
    fi

    git add -u
    git commit $no_verify -m "${prefix}${message}"
    git push
}

# https://www.youtube.com/watch?v=lZehYwOfJAs
recent-branch() {
	git branch --sort=-committerdate | fzf --header "Checkout Recent Branch" --preview "git diff {1} --color=always" | xargs git checkout
}
alias rb=recent-branch

lg()
{
    export LAZYGIT_NEW_DIR_FILE=~/.lazygit/newdir

    lazygit "$@"

    if [ -f $LAZYGIT_NEW_DIR_FILE ]; then
            cd "$(cat $LAZYGIT_NEW_DIR_FILE)"
            rm -f $LAZYGIT_NEW_DIR_FILE > /dev/null
    fi
}
# things for the `lc` command
LC_DELIMITER_START="⋮";
LC_DELIMITER_END="⭐";
