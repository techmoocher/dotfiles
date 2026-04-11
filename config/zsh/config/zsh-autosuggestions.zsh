autoload -Uz compinit
compinit

ZSH_AUTOSUGGEST_USE_ASYNC=1
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#5c5c5c'
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_CLEAR_WIDGETS=(
  history-search-forward
  history-search-backward
  history-beginning-search-forward
  history-beginning-search-backward
)

#bindkey '^ ' autosuggest-accept   # Ctrl + Space

zstyle ':completion:*' menu select
zstyle ':completion::complete:*' gain-privileges 1
