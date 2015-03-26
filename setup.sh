#!/bin/bash
BASH_PROFILE_URL="https://raw.githubusercontent.com/EddyLuten/bash_profile/master/.bash_profile"

command_failed()
{
  [ $? -ne 0 ]
}
command_succeeded()
{
  [ $? -eq 0 ]
}

ask_user()
{
  echo "$1 (y/n)"
  read USER_RESULT

  echo "$USER_RESULT" | grep -i "y" &> /dev/null
  if command_succeeded; then
    return 0
  else
    return 1
  fi
}

# OS X Settings
defaults write com.apple.finder AppleShowAllFiles -bool YES
defaults write com.apple.finder _FXShowPosixPathInTitle -bool YES
defaults write com.apple.finder ShowPathBar -bool YES
defaults write com.apple.finder AppleShowAllExtensions -bool YES
killall Finder

# Prompt to install xcode command line tools
if ask_user "Do you wish to install Xcode command line tools?"; then
  echo 'Installing Xcode command line tools...'
  xcode-select --install # Will prompt
  echo 'IMPORTANT: please let the Xcode installation finish before continuing.'
else
  echo 'Not installing Xcode command line tools.'
fi

# Install required tools
brew --version &> /dev/null
if command_failed; then
  echo 'Installing homebrew...'
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  brew doctor
else
  echo 'Updating homebrew...'
  brew update
fi

# See what's installed already and store it in a variable
BREW_LIST=$(brew list)

# Install brew cask for installing applications
echo "$BREW_LIST" | grep brew-cask &> /dev/null
if command_failed; then
  brew install caskroom/cask/brew-cask
fi

# Install wget
wget -V -nv &> /dev/null
if command_failed; then
  echo 'Installing wget...'
  brew install wget
fi

# Install Vim
echo "$BREW_LIST" | grep vim &> /dev/null
if command_failed; then
  echo 'Installing Vim...'
  brew install vim
  brew install macvim --override-system-vim
fi

# Install git
echo "$BREW_LIST"  | grep git &> /dev/null
if command_failed; then
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
fi

# Install node.js
node --version &> /dev/null
if command_failed; then
  echo 'Installing node.js...'
  brew install node
fi

# Install rbenv
rbenv --version &> /dev/null
if command_failed; then
  echo 'Installing rbenv...'
  brew install rbenv ruby-build
fi

# Ensure that a .bash_profile exists
if ask_user "Do you wish to install a default .bash_profile?"; then
  echo 'Downloading a default .bash_profile...'
  wget -q -O ~/.bash_profile "$BASH_PROFILE_URL"
  chmod +x ~/.bash_profile
  source ~/.bash_profile
else
  echo 'Using the existing .bash_profile or creating an empty one...'
  touch -a ~/.bash_profile
fi

# Add the rbenv initialization to .bash_profile
grep 'rbenv init' ~/.bash_profile &> /dev/null
if command_failed; then
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
  rbenv install "$USER_RUBY_VERSION"

  if command_succeeded; then
    if ask_user 'Do you wish to make this the default (global) Ruby version?'; then
      rbenv global "$USER_RUBY_VERSION"
    fi
  else
    echo 'Ruby installation failed.'
  fi
fi

if ask_user "Do you wish to install commonly used applications now?"; then
  CASK_LIST=$(brew cask list)
  APPS_LIST=$(ls /Applications/)
  BOTH_LISTS="$CASK_LIST\nAPPS_LIST"

  # Install Atom
  printf "$BOTH_LISTS" | egrep -i "atom(.app)?" &> /dev/null
  if command_failed; then
    echo 'Installing Atom...'
    brew cask install atom
    brew cask install atom-shell
  fi

  # Install Google Chrome
  echo "$BOTH_LISTS" | egrep -i "google[ -]chrome(.app)?" &> /dev/null
  if command_failed; then
    echo 'Installing Google Chrome...'
    brew cask install google-chrome
  fi

  # Install Firefox
  echo "$BOTH_LISTS" | egrep -i "firefox(.app)?" &> /dev/null
  if command_failed; then
    echo 'Installing Firefox...'
    brew cask install firefox
  fi

  # Install iTerm2
  echo "$BOTH_LISTS" | egrep -i "iterm2" &> /dev/null
  if command_failed; then
    echo 'Installing iTerm2...'
    brew cask install iterm2
  fi
fi

echo 'All done! You may have to open a new Terminal window if you chose to'
echo 'install a default .bash_profile and wish for the changes to take effect.'
