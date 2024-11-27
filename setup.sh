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
  curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

  # yazi
  LATEST_VERSION=$(curl -s https://api.github.com/repos/sxyazi/yazi/releases/latest | grep -o '"tag_name": ".*"' | cut -d'"' -f4)

  TEMP_DIR=$(mktemp -d)
  cd "$TEMP_DIR"

  curl -LO "https://github.com/sxyazi/yazi/releases/download/${LATEST_VERSION}/yazi-x86_64-unknown-linux-gnu.zip"
  unzip yazi-x86_64-unknown-linux-gnu.zip

  sudo mkdir -p /usr/local/bin
  sudo mv yazi-x86_64-unknown-linux-gnu/{ya,yazi} /usr/local/bin/
  sudo chmod +x /usr/local/bin/{yz,yazi}

  curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /etc/apt/keyrings/wezterm-fury.gpg
  echo 'deb [signed-by=/etc/apt/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list

  sudo apt update
  sudo apt install -y wezterm
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
  cp ~/.template/zshrc ~/.zshrc
}

set_default_shell() {
  echo "Setting zsh as default shell..."
  chsh -s $(which zsh)
}

main() {
  setup_base
  install_ohmyzsh
  install_tools
  set_default_shell
  yazi_config
  zsh_configs

  echo "Installation complete! Please log out and log back in to start using zsh."
}
main