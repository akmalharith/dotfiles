#!/bin/bash
do_it () {
    set -x 

    # Set passwordless sudo
    if sudo grep -xqFe "$USER ALL=(ALL) NOPASSWD:ALL" /etc/sudoers
    then
        echo "Found NOPASSWD entry. Skipping."

    else
        echo "NOPASSWD entry not found. Adding a new entry."
        echo "$USER ALL=(ALL) NOPASSWD:ALL" | sudo EDITOR='tee -a' visudo

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


    if [ -f "$HOME/.bash_profile" ]; then
        echo ".bash_profile found."
        # Disable other shell profiles
        test -f "$HOME/.bashrc" && mv "$HOME/.bashrc" "$HOME/.bashrc.bak"
        test -f "$HOME/.bash_profile" && mv "$HOME/.bash_profile" "$HOME/.bash_profile.bak"
        test -f "$HOME/.zsh_profile" && mv "$HOME/.zsh_profile" "$HOME/.zsh_profile.bak"
        test -f "$HOME/.aliases" && mv "$HOME/.aliases" "$HOME/.aliases.bak"
    fi
    
    # TODO: Install oh-my-zsh
    # sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    # Overwrite oh-my-zsh themes
    

    # TODO: Switch to different shells here
    # echo $SHELL
    # Copy dotfiles to home directory
    cp \
    .aliases \
    .bashrc \
    .bash_profile \
    .curlrc \
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

    source ~/.bash_profile;
    set +x
}

read -p "This may overwrite existing files in your home directory. Are you sure? [y/N] " -n 1;
echo "";

if [ "${REPLY,,}" == "y" ]; then
    do_it;

fi;
