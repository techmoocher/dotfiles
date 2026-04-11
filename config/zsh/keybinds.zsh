###### KEYBINDS ######

bindkey -e
bindkey "\e[3~" delete-char             # Delete
bindkey '^[[1;5D' backward-word         # Ctrl + Left
bindkey '^[[1;5C' forward-word          # Ctrl + Right
# bindkey '^[[5D' backward-word
# bindkey '^[[5C' forward-word
bindkey '^H' backward-kill-word         # Ctrl + Backspace
bindkey '^[^?' backward-kill-word

# Ctrl + Delete
bindkey '^[[3;5~' kill-word        # kitty
bindkey '^[[3;9~' kill-word        # wezterm
bindkey '^[[3;7~' kill-word        # alacritty