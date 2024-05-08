if status is-interactive
    # Commands to run in interactive sessions can go here
end

# ? Removes fish greetings message
set fish_greeting ""

# # PATH
# set -x ANDROID_BUILD_TOOLS "$ANDROID_HOME/build-tools/33.0.0/"
set -gx VOLTA_HOME "$HOME/.volta"
set -x PNPM_HOME "$HOME/.local/share/pnpm"
set -x DENO_INSTALL "$HOME/.deno"
set -x GOPATH "$HOME/.go"
set -x ANDROID_HOME "$HOME/Android/Sdk"
set -x VOLTA_HOME "$HOME/.volta"
set -x BUN_INSTALL "$HOME/.bun"
set -x HOMEBREW_PREFIX "/home/linuxbrew/.linuxbrew"

# # Add folders to path
# fish_add_path $CHROMEDRIVER_PATH
# fish_add_path $ANDROID_BUILD_TOOLS
fish_add_path $PNPM_HOME
fish_add_path $GOPATH/bin
fish_add_path $VOLTA_HOME/bin
fish_add_path $DENO_INSTALL/bin
fish_add_path $HOME/.local/bin
fish_add_path $HOME/.cargo/bin
fish_add_path $ANDROID_HOME/emulator
fish_add_path $ANDROID_HOME/platform-tools
fish_add_path $BUN_INSTALL/bin
fish_add_path $HOMEBREW_PREFIX/bin
fish_add_path $HOMEBREW_PREFIX/sbin

# # pnpm completions
# tabtab source for packages
# uninstall by removing these lines
[ -f ~/.config/tabtab/fish/__tabtab.fish ]; and . ~/.config/tabtab/fish/__tabtab.fish; or true

# # nb completions
[ -f ~/.config/fish/completions/nb.fish ]; and . ~/.config/fish/completions/nb.fish; or true

# brew
if test -d (brew --prefix)"/share/fish/completions"
    set -p fish_complete_path (brew --prefix)/share/fish/completions
end

if test -d (brew --prefix)"/share/fish/vendor_completions.d"
    set -p fish_complete_path (brew --prefix)/share/fish/vendor_completions.d
end

# # Aliases
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
alias tbox='SHELL=/usr/bin/fish toolbox -r 38 enter'
alias trun='SHELL=/usr/bin/fish toolbox -r 38 run $argv'
alias firefox='flatpak-spawn --host firefox'
alias code='flatpak run com.visualstudio.code'
#alias code='toolbox run -c fedora-toolbox-38 /usr/share/code/code &'

# Hide jrnl entries
abbr --add jrnl " jrnl"

# # Function Helpers
function count_files
    find . -type f | wc -l
end

function repl
    NODE_PATH=(pnpm root -g) node
end

function exifclear
    flatpak run fr.romainvigier.MetadataCleaner
end

# findport `port`
function findport
    lsof -nP -iTCP -sTCP:LISTEN | grep "$argv"
end

# Replaces trash command to include clear subcommand
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

# Add 'greeting message'
function fish_greeting
    PF_INFO="ascii title os kernel de shell uptime" pfetch
end

# Replace rm with a safer command
if command -v trash > /dev/null
    unalias rm &> /dev/null
    alias rm='trash'
end

# Replace ls
if command -v eza > /dev/null
    unalias ll &> /dev/null
    unalias l &> /dev/null
    unalias la &> /dev/null
    unalias ls &> /dev/null
    alias ls='eza -G --color auto --icons -s type'
    alias ll='eza -l --color always --icons -a -s type'
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
