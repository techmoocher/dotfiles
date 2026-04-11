### OPTIONS ###

# History
HISTFILE=$HOME/.zsh_history
HISTSIZE=5000
SAVEHIST=5000
HISTORY_IGNORE="(la|ls|pwd|exit|clear|whoami|nvim|yazi|y|fastfetch|ff)"

setopt HIST_IGNORE_SPACE
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY

# Plugins
source $HOME/.config/zsh/config/zsh-autosuggestions.zsh
source $HOME/.config/zsh/config/fsh.zsh
