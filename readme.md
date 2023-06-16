# dotfiles

`bash` dotfiles. `zsh` support soon.

## Pre-requisites

For Windows, setup WSL2 by running `.windows/SetupDevelopmentTools.ps1` as administrator.

## Installation

### Git

(Optional) Install zsh and change to zsh before running `bootstrap.sh`.
```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
```

Executing the bootstrap.
```
git clone https://github.com/akmalharith/dotfiles.git && cd dotfiles && source bootstrap.sh
```
