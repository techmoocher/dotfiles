autoload -Uz compinit
compinit

zstyle ':completion:*' menu select
zstyle ':completion::complete:*' gain-privileges 1

zstyle ':fast-highlight:*' default         fg=white
zstyle ':fast-highlight:*' command         fg=cyan
zstyle ':fast-highlight:*' builtin         fg=blue
zstyle ':fast-highlight:*' string          fg=yellow
zstyle ':fast-highlight:*' variable        fg=green
zstyle ':fast-highlight:*' path            fg=yellow
zstyle ':fast-highlight:*' comment         fg=brightblack
zstyle ':fast-highlight:*' unknown-token   fg=red,bold
