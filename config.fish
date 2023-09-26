if status is-interactive
    # Commands to run in interactive sessions can go here
end

# ? Removes fish greetings message
set fish_greeting ""
set -x PNPM_HOME "$HOME/.local/share/pnpm"
set -x DENO_INSTALL "$HOME/.deno"
set -x GOPATH "$HOME/.go"
set -x ANDROID_HOME "$HOME/Android/Sdk"
set -x ANDROID_BUILD_TOOLS "$ANDROID_HOME/build-tools/33.0.0/"
set -x CHROMEDRIVER_PATH "/home/vicente/.cache/selenium/chromedriver/linux64/113.0.5672.63/chromedriver"
set -x VOLTA_HOME "$HOME/.volta"
# set -x PATH "$CHROMEDRIVER_PATH" "$ANDROID_BUILD_TOOLS" "$GOPATH/bin" "$PNPM_HOME" "$DENO_INSTALL/bin" "$HOME/.local/bin" $PATH



# # Add folders to path
fish_add_path $CHROMEDRIVER_PATH
fish_add_path $ANDROID_BUILD_TOOLS
fish_add_path $GOPATH/bin
fish_add_path $PNPM_HOME
fish_add_path $DENO_INSTALL/bin
fish_add_path $HOME/.local/bin
fish_add_path $VOLTA_HOME/bin
set -U fish_user_paths $HOME/.cargo/bin $fish_user_paths

# # pnpm completions
# tabtab source for packages
# uninstall by removing these lines
[ -f ~/.config/tabtab/fish/__tabtab.fish ]; and . ~/.config/tabtab/fish/__tabtab.fish; or true

# Helpers
function count_files
    find . -type f | wc -l
end

function repl
    NODE_PATH=(pnpm root -g) node
end

function exifclear
    flatpak run fr.romainvigier.MetadataCleaner
end

# # Easy access to folders
alias i='cd $HOME/i'
alias clones='cd $HOME/i/_clones'
alias forks='cd $HOME/i/_forks'
alias issues='cd $HOME/i/_issues'
alias ii='cd $HOME/ii'
alias v='cd $HOME/v'
alias tmp='cd $HOME/tmp'
alias h='cd $HOME'
alias lsd='ls | lolcat'
alias open='open-cli'
alias gedit='flatpak run org.gnome.TextEditor'

# findport `port`
function findport
    lsof -nP -iTCP -sTCP:LISTEN | grep "$argv"
end

# # Replaces trash command to include clear subcommand
# https://www.npmjs.com/package/trash-cli
# https://www.npmjs.com/package/empty-trash-cli
function trash
    switch "$argv[1]"
        case --clear
            empty-trash
        case '*'
            command trash $argv
    end
end

## # Add 'greeting message'
function fish_greeting
    PF_INFO="ascii title os kernel  de shell uptime" pfetch
end

# Replace rm with a safer command
if command -v trash > /dev/null
    unalias rm &> /dev/null
    alias rm='trash'
end

# Replace ls
if command -v exa > /dev/null
    unalias ll &> /dev/null
    unalias l &> /dev/null
    unalias la &> /dev/null
    unalias ls &> /dev/null
    alias ls='exa -G --color auto --icons -s type'
    alias ll='exa -l --color always --icons -a -s type'
end

# Replace cat
if command -v bat > /dev/null
    unalias cat &> /dev/null
    alias cat='bat --paging=never -n --theme="OneHalfDark"'
end

# Wayland copy to clipboard
if command -v wl-copy > /dev/null
    unalias cb &> /dev/null
    unalias pb &> /dev/null
    alias cb='wl-copy'
    alias pb='wl-paste'
end

starship init fish | source
