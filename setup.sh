#!/bin/bash

setup_base() {
  echo "Installing base packages..."
  sudo apt update
  sudo apt install -y curl git zsh unzip
}

install_ohmyzsh() {
  echo "Installing oh-my-zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  echo "Installing zsh plugins"
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
  git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  git clone https://github.com/Aloxaf/fzf-tab ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab
}

install_tools() {
  echo "Installing additional tools..."

  # fzf
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install -all

  sudo apt install -y ffmpeg ripgrep jq fd-find
  # zoxide
  sh -c "$(curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh)" "" --unattended

  # yazi
  LATEST_VERSION=$(curl -s https://api.github.com/repos/sxyazi/yazi/releases/latest | grep -o '"tag_name": ".*"' | cut -d'"' -f4)

  TEMP_DIR=$(mktemp -d)
  cd "$TEMP_DIR"

  curl -LO "https://github.com/sxyazi/yazi/releases/download/${LATEST_VERSION}/yazi-x86_64-unknown-linux-gnu.zip"
  unzip yazi-x86_64-unknown-linux-gnu.zip

  sudo mkdir -p /usr/local/bin
  sudo mv yazi-x86_64-unknown-linux-gnu/{ya,yazi} /usr/local/bin/
  sudo chmod +x /usr/local/bin/{yz,yazi}

}

yazi_config() {
  mkdri -p ~/.config
  mv yazi/ ~/.config/yazi/
  /usr/local/bin/ya pack -a yazi-rs/plugins:git
  /usr/local/bin/ya pack -a yazi-rs/plugins:diff
  /usr/local/bin/ya pack -a yazi-rs/plugins:full-border
  /usr/local/bin/ya pack -a yazi-rs/plugins:jump-to-char
  /usr/local/bin/ya pack -a yazi-rs/plugins:smart-filter
  /usr/local/bin/ya pack -a yazi-rs/plugins:lsar
  /usr/local/bin/ya pack -a stelcodes/bunny
  /usr/local/bin/ya pack -a Lil-Dank/lazygit

  git clone https://github.com/yazi-rs/flavors.git ~/.config/yazi/
}

zsh_configs() {
  echo "Setting up configurations..."
  cat >~/.zshrc <<'EOL'
export PATH="$PATH:$HOME/.local/bin"
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"
HYPHEN_INSENSITIVE="true"

zstyle ':omz:update' mode auto
zstyle ':omz:update' frequency 13
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls $realpath'

ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"
plugins=(
  git
  zsh-syntax-highlighting
  zsh-completions
  zsh-autosuggestions
  fzf-tab
  bundler
  compleat
  fzf
  vi-mode
)
source $ZSH/oh-my-zsh.sh

function yy() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

bindkey -v
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

_z_cd() {
    cd "$@" || return "$?"
    if [ "$_ZO_ECHO" = "1" ]; then
        echo "$PWD"
    fi
}

z() {
    if [ "$#" -eq 0 ]; then
        _z_cd ~
    elif [ "$#" -eq 1 ] && [ "$1" = '-' ]; then
        if [ -n "$OLDPWD" ]; then
            _z_cd "$OLDPWD"
        else
            echo 'zoxide: $OLDPWD is not set'
            return 1
        fi
    else
        _zoxide_result="$(zoxide query -- "$@")" && _z_cd "$_zoxide_result"
    fi
}

zi() {
    _zoxide_result="$(zoxide query -i -- "$@")" && _z_cd "$_zoxide_result"
}


alias za='zoxide add'
alias zq='zoxide query'
alias zqi='zoxide query -i'

alias zr='zoxide remove'
zri() {
    _zoxide_result="$(zoxide query -i -- "$@")" && zoxide remove "$_zoxide_result"
}

_zoxide_hook() {
    zoxide add "$(pwd -L)"
}

chpwd_functions=(${chpwd_functions[@]} "_zoxide_hook")

alias ll="ls -la $@"
EOL
}

set_default_shell() {
  echo "Setting zsh as default shell..."
  chsh -s $(which zsh)
}

main() {
  setup_base
  install_ohmyzsh
  install_tools
  yazi_config
  zsh_configs
  set_default_shell

  echo "Installation complete! Please log out and log back in to start using zsh."
}
main