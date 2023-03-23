#!/bin/bash

if [ "$1" == "--force" -o "$1" == "-f" ]; then
	
else
	read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1;
	echo "";
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		doIt;
	fi;
fi;


# Setup pre-requisites
brew.sh
#!/bin/bash
which -s brew
if [[ $? != 0 ]] ; then
    if [[ "$OSTYPE" == "linux-gnu"* ]] || [[ "$OSTYPE" == "darwin"* ]]; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        echo "Unsupported OSTYPE $OSTYPE" 1>&2
        exit 125
    fi
else
    brew update
fi

brew bundle --force cleanup
brew bundle --file="Brewfile"

which -s pip
if [[ $? != 0 ]] ; then
	echo "pip not found" 1>&2
	exit 125
else
    pip install -r packages.txt
fi