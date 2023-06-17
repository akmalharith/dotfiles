#!/bin/bash
# Only run this in your default shell
# If you want to use zsh, change your default shell to zsh

do_it () {
    set -x 
    # Set passwordless sudo
    # May not be possible for remote DE eg: gitpod
    if [[ "$USER" != "gitpod" ]];
    then
        if sudo grep -xqFe "$USER ALL=(ALL) NOPASSWD:ALL" /etc/sudoers
        then
        echo "Found NOPASSWD entry. Skipping."
        else
        echo "NOPASSWD entry not found. Adding a new entry."
        echo "$USER ALL=(ALL) NOPASSWD:ALL" | sudo EDITOR='tee -a' visudo
        fi
    fi

    # Setup homebrew
    which brew
    if [[ $? != 0 ]];
    then
        if [[ "$OSTYPE" == "linux-gnu"* ]] || [[ "$OSTYPE" == "darwin"* ]]; 
        then

            echo "Installing homebrew"
            NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

            if [[ "$OSTYPE" == "linux-gnu"* ]];
            then
                sudo apt-get update -y 
                sudo apt-get install build-essential -y

                test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
                test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
                test -r ~/.bash_profile && echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >> ~/.bash_profile
                echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >> ~/.profile
            fi
                        
        else
            echo "Unsupported OSTYPE $OSTYPE" 1>&2
            exit 125
        fi
    else
        echo "Found homebrew. Trying to update."
        brew update
    fi

    brew bundle --force cleanup
    brew bundle --file="Brewfile"

    which pip3
    if [[ $? != 0 ]]; 
    then
        
        echo "pip3 not found" 1>&2
        # TODO: Setup pip here?
        exit 125

    else
        echo "Installing pip packages here."
        pip3 install -r packages.txt
    fi 


    if [ -f "$HOME/.profile" ]; then
        echo ".profile found."

        # Disable other shell profiles 
        # by performing a backup of them in ~/.profile_bak/bak/

        profile_files=("bashrc" "bash_profile" "zshrc" "zsh_profile" "aliases")

        mkdir -p ~/.profile_bak/bak/

        for i in "${profile_files[@]}"
        do
            test -f "$HOME/.$i" && mv "$HOME/.$i" "$HOME/.$i.bak"
            echo "$i"
        done
    fi

    # Copy dotfiles to home directory
    cp \
    .zshrc \
    .bashrc \
    .aliases \
    .tools \
    .curlrc \
    .profile \
    .gitconfig \
    .hushlogin \
    $HOME/
    
    # Copy folders
    TF_CREDS=.terraform.d/credentials.tfrc.json
    if [ -f "$HOME/$TF_CREDS" ]; then
        echo "Current $TF_CREDS exists."
    else 
        echo "$TF_CREDS does not exist. Copying placeholder credentials."
        cp $TF_CREDS $HOME/$TF_CREDS
    fi
    
    # Universal source profile
    if [ $SHELL == "/bin/bash" ]; then 
        # cp ~/.bashrc ~/.bashrc
        
        source ~/.bashrc
        
    elif [ $SHELL == "/bin/zsh" ]; then
        
        # Copy oh-my-zsh agnoster theme
        # mkdir -p ~/.oh-my-zsh/themes
        # cp dotfiles/.oh-my-zsh/themes/agnoster.zsh-theme ~/.oh-my-zsh/themes/agnoster.zsh-theme

        source ~/.zshrc
    fi 
    set +x
}

read -p "This may overwrite existing files in your home directory. Are you sure? [y/N] " -n 1;
echo "";

if [ "${REPLY,,}" == "y" ]; then
    do_it;
fi;
