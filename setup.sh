#!/bin/bash

ask_user()
{
  echo "$1 (y/n)"
  read USER_RESULT

  echo "$USER_RESULT" | grep -i "y"
  if [ $? -eq 0 ]; then
    return 0
  else
    return 1
  fi
}

# OS X Settings
defaults write com.apple.finder AppleShowAllFiles YES
killall Finder

# Prompt to install xcode command line tools
if ask_user "Do you wish to install xcode command line tools?"; then
  echo 'Installing xcode command line tools...'
  xcode-select --install # Will prompt
  echo 'IMPORTANT: please let the xcode installation finish before continuing.'
else
  echo 'Not installing xcode command line tools.'
fi

# Install required tools
brew --version &> /dev/null
if [ ! $? -eq 0 ]; then
  echo 'Installing homebrew...'
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  brew doctor
else
  echo 'Updating homebrew...'
  brew update
fi

# Install wget
wget -V -nv &> /dev/null
if [ ! $? -eq 0 ]; then
  echo 'Installing wget...'
  brew install wget
else
  echo 'Upgrading wget...'
  brew upgrade wget
fi

# Install git
brew list | grep git
if [ ! $? -eq 0 ]; then
  echo 'Installing git...'
  brew install git

  # Configure git
  if ask_user 'Do you wish to configure git now?'; then
    echo 'Please enter your full name:'
    read GIT_USER

    echo 'Please enter your email address:'
    read GIT_EMAIL

    git config --global user.name "$GIT_USER"
    git config --global user.email "$GIT_EMAIL"
  fi
else
  echo 'Upgrading git...'
  brew upgrade git
fi

# Install node.js
node --version &> /dev/null
if [ ! $? -eq 0 ]; then
  echo 'Installing node.js...'
  brew install node
else
  echo 'Upgrading node.js...'
  brew upgrade node
fi

# Install rbenv
rbenv --version &> /dev/null
if [ ! $? -eq 0 ]; then
  echo 'Installing rbenv...'
  brew install rbenv ruby-build
else
  echo 'Upgrading rbenv...'
  brew upgrade rbenv ruby-build
fi

# Ensure that a .bash_profile exists
if ask_user "Do you wish to install a default .bash_profile?"; then
  echo 'Downloading a default .bash_profile...'
  wget -q -O ~/.bash_profile http://bit.ly/1zEPNup
  chmod +x ~/.bash_profile
  source ~/.bash_profile
else
  echo 'Using the existing .bash_profile or creating an empty one...'
  touch -a ~/.bash_profile
fi

# Add the rbenv initialization to .bash_profile
grep 'rbenv init' ~/.bash_profile &> /dev/null
if [ ! $? -eq 0 ]; then
  echo 'Adding rbenv init to .bash_profile...'
  echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
  source ~/.bash_profile
fi

# Optionally install a ruby version
if ask_user "Do you wish to install a specific Ruby version now?"; then
  rbenv install -l | sed -e "s/Available versions://g" | column
  echo 'Please enter the version you wish to install:'
  read USER_RUBY_VERSION
  echo "Installing Ruby $USER_RUBY_VERSION..."
  rbenv install $USER_RUBY_VERSION

  if [ $? -eq 0 ]; then
    if ask_user 'Do you wish to make this the default (global) Ruby version?'; then
      rbenv global $USER_RUBY_VERSION
    fi
  else
    echo 'Ruby installation failed.'
  fi
fi

echo 'All done! You may have to open a new Terminal window if you chose to'
echo 'install a default .bash_profile and wish for the changes to take effect.'
