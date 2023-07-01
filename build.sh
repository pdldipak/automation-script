#!/bin/bash

## give absolute path
VUE_DIR="/var/www/${path}"
cd "$VUE_DIR" || exit 1

# required node version
NODE_VERSION=14.20.1

## check and load NVM
if [ -f ~/.nvm/nvm.sh ]; then
  echo 'sourcing nvm from ~/.nvm'
  . ~/.nvm/nvm.sh
else
  echo "NVM is not installed. Please install NVM first."
  exit 1
fi

# Check if desired version is already installed
if nvm ls "$NODE_VERSION" | grep -q "$NODE_VERSION"; then
  echo "Node.js version $NODE_VERSION is already installed."
else
  echo "Node.js version $NODE_VERSION is not installed. Installing..."
  nvm install "$NODE_VERSION"
  npm install --unsafe-perm
fi

# condition to check theme
function  _get_build_theme() {
  theme=${1,,}

  case $theme in
    dark|dr|)
      theme="black"
      ;;

    *)
      theme="white"
      ;;
  esac

  echo "$theme"
}

function _change_node_version_to () {
  if [[ ! $1 =~ ^[+-]?[0-9]+\.?[0-9]*+?\.?[0-9]*$ ]]; then
    _die "Missing argument or not a number"
  fi
  nvm use "$1"
  nvm alias default "$1"

  echo "Active Node version: "$(node -v | sed 's/^v//')
}

_change_node_version_to "$NODE_VERSION"

PROCESS=$1
BRAND=$2
ENV=development

THEME=$(_get_build_theme "${BRAND}")


## animation during build/dev process
frames=("◉ ● ○" "○ ◉ ●" "● ○ ◉")

if [[ -n $THEME && $PROCESS == "build" ]]; then
  # Loop through the frames for the animation
  for frame in "${frames[@]}"; do
    echo -ne "\e[32m${frame}\e[0m"
    sleep 0.5
    echo -en "\r"
  done
  echo "$(tput setaf 3)$(tput bold)Now you are running in build mode for $THEME !$(tput sgr0)"
  npm run build --theme="$THEME" --env="$ENV"
else
  # Loop through the frames for the animation
  for frame in "${frames[@]}"; do
    echo -ne "\e[32m${frame}\e[0m"
    sleep 0.5
    echo -en "\r"
  done
  echo "$(tput setaf 3)$(tput bold)Now you are running in dev mode for $THEME !$(tput sgr0)"
  npm run dev --theme="$THEME"
fi 
