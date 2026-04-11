###### FUNCTIONS ######

# yazi
function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd < "$tmp"
  [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
  rm -f -- "$tmp"
}

# fastfetch (shuffle logo images)
function ff() {
  fastfetch --logo "$(find ~/hyprland-dotfiles/.config/fastfetch/images -type f | shuf -n 1)"
}

# source .zshrc
function szsh() {
  if [ -f "$HOME/.zshrc" ]; then
    source "$HOME/.zshrc"
    echo "Sourced ~/.zshrc"
  elif [ -f "$HOME/.config/zsh/.zshrc" ]; then
    source "$HOME/.config/zsh/.zshrc"
    echo "Sourced ~/.config/zsh/.zshrc"
  else
    echo "zsh config not found"
  fi
}
