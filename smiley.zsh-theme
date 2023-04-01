# custom theme with a smiley for exit code showing

# enable alert
ALERT_ENABLE=1

# threshold for alert
ALERT_THRSH=10

# alert sound
# available sounds:
# Basso, Blow, Bottle, Frog, Funk, Glass, Hero
# Morse, Ping, Pop, Purr, Sosumi, Submarine, Tink
ALERT_SOUND="Ping"

# commands that do not have alarm
ALERT_IGNORED=(zsh vim)

NL=$'\n'
GRN='%F{10}'
YLW='%F{11}'
RED='%F{9}'
BLU='%F{12}'
CYN='%F{14}'
WHT='%F{15}'
GRY='%F{8}'

BEHIND='%F{202}'
AHEAD='%F{151}'

STAGED='%F{2}'
CHANGED='%F{32}'
DELETED='%F{1}'
UNTRACKED='%F{8}'
STASHED='%F{12}'
CONFLICTS='%F{160}'

# need to save exit code right after cmd execution
function save_exit_code() {
    EXIT_CODE=$?
}

add-zsh-hook precmd save_exit_code

function save_start_time() {
    CMD_EXECUTED="$1"
    START_TIME=$SECONDS
}

function save_end_time() {
    if [[ -v CMD_EXECUTED ]] ; then
        ELAPSED=$(( SECONDS - START_TIME ))
        CMD=$(echo "$CMD_EXECUTED" | head -n1 | awk '{print $1;}')
        if [[ -v ALERT_ENABLED ]] && [[ $ELAPSED -ge $ALERT_THRSH ]] && [[ $ALERT_IGNORED[(I)$CMD] -eq 0 ]] ; then
            MSG="display notification \"Elapsed time: $ELAPSED seconds\" with title \"$CMD_EXECUTED\" subtitle \"Execution finished\" sound name \"$ALERT_SOUND\""
            osascript -e $MSG
        fi
        unset CMD_EXECUTED
    fi
}

add-zsh-hook preexec save_start_time
add-zsh-hook precmd save_end_time

# prints smiley depending on last cmd's exit code
function exit_prompt_info() {
    if [[ $EXIT_CODE -eq 0 ]]; then
        echo "${GRN}^_^%f"
    else
        if [[ $EXIT_CODE -lt 128 ]]; then
            echo "${RED}-_-%f"
        else
            echo "${WHT}x_x%f"
        fi
    fi
}

# outputs all terminal colors
function test_colors() {
    for x in {0..16}; do
        for y in {0..16}; do
            z=$((x*16+y))
            echo -n "%F{$z}${(l:3::0:)z} "
        done
        echo
    done
}

# prints running time for last command if nonzero
function cmd_running_time() {
    if [[ $ELAPSED -gt 1 ]]; then
        echo "⌛%{${WHT}%}${ELAPSED}%fs"
    fi
}

# set the appearance of the git info
ZSH_THEME_GIT_PROMPT_PREFIX=" "

ZSH_THEME_GIT_PROMPT_BRANCH="${CYN}"

ZSH_THEME_GIT_PROMPT_BEHIND=" ${BEHIND}%{↓%G%}"
ZSH_THEME_GIT_PROMPT_AHEAD=" ${AHEAD}%{↑%G%}"

ZSH_THEME_GIT_PROMPT_SEPARATOR=""

ZSH_THEME_GIT_PROMPT_STAGED=" ${STAGED}●${WHT}"
ZSH_THEME_GIT_PROMPT_CONFLICTS=" ${CONFLICTS}✖${WHT}"
ZSH_THEME_GIT_PROMPT_CHANGED=" ${CHANGED}✚${WHT}"
ZSH_THEME_GIT_PROMPT_DELETED=" ${DELETED}-${WHT}"
ZSH_THEME_GIT_PROMPT_UNTRACKED=" ${UNTRACKED}…"
ZSH_THEME_GIT_PROMPT_STASHED=" ${STASHED}⚑${WHT}"

ZSH_THEME_GIT_PROMPT_CLEAN=""

# not used
ZSH_THEME_GIT_PROMPT_UPSTREAM_SEPARATOR="->"

ZSH_THEME_GIT_PROMPT_SUFFIX=""

setopt prompt_subst

# hide git-prompt
RPROMPT=''

PROMPT='⟨${BLU}%~%f$(git_super_status)%f⟩ $(cmd_running_time)${NL}'
PROMPT+='($(exit_prompt_info))[${GRN}%n%B${WHT}@%b${GRN}%m%f]%B${WHT}%%%b%f '

