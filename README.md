# Personal Bash Resources

Welcome to the **Personal Bash Resources** repository! This collection of bash functions and resources is designed to automate and simplify a wide variety of tasks, making your programming and daily activities more efficient.

## Overview

This repository includes a diverse set of bash scripts and functions that can help with:

- **Media Manipulation**: Automate tasks like converting, resizing, or organizing media files.
- **File and Directory Management**: Simplify tasks such as renaming, moving, or organizing files and directories.
- **Development Environment Setup**: Set up development environment for different languages

### Original Purpose

The original purpose of this repository was to provide an easy way to package up my shell environment and move it between computers. This allows for seamless uploading of the configuration to a repository or cloud storage, enabling easy retrieval and setup on another computer later. This approach ensures consistency and efficiency across different working environments and computers, since working in tech basically ensures that you are going to be laid off many times as companies shrink and expand.

I got so fed up with having to reinstall everything, remember all of my git aliases, install all of the dependencies for my development environment... It is the worst when trying to onboard to a new company, or even continue side projects that I was previously working on.

This project changes all of that. Now my .zshrc file looks like this:
```
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(git)

source $ZSH/oh-my-zsh.sh

PBR_DIR=$HOME/personal-bash-resources
source $PBR_DIR/main.sh
```

### Getting Started

**Please note** - this repository is designed for MacOS and Linux. There are no plans to adapt it for Windows usage.

If you use a .bashrc or some other shell configuration for your shell then you will need to substitute the appropriate shell configuration filename in the following commands: `.zshrc` becomes `.bashrc`

**Please note** - The following commands to get started will install this repository to your home directory in your shell. This is intentional as this will put it next to where the bashrc or zshrc or other shell configuration file will most likely be installed. However, you can update the following commands to install it wherever you would like. Just be sure to double check that you use the same exact location in both steps 1 and 2, and you will need to change step 1 so that the INSTALL_LOCATION variable goes to wherever you want it to go.

1. Set a temporary bash variable to store the location where personal bash resources will be installed, by default this command will try to install it in your home directory
   ```
   INSTALL_LOCATION=$HOME
   ```

2. Clone the repository to the location specified by `INSTALL_LOCATION`:
   ```
   git clone https://github.com/TheTechChild/personal-bash-resources.git $INSTALL_LOCATION/personal-bash-resources
   ```

3. Use the following terminal commands to update your .zshrc file and integrate personal bash resources into your shell configuration, giving you access to these goodies:
   ```
   echo "PBR_DIR=$INSTALL_LOCATION" >> ~/.zshrc
   echo "source $INSTALL_LOCATION/personal-bash-resources/main.sh" >> ~/.zshrc
   ```

4. Reload your shell configuration:
   ```
   source ~/.zshrc
   ```

## Usage

Each script or function is documented with usage instructions. To see a list of available functions, you can run: `list-functions`

For detailed usage of a specific function, use: `function-name --help`

## Contributing

Contributions are welcome! If you have a bash function or script that you think would be a great addition, feel free to fork the repository and submit a pull request.

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

---

Feel free to customize this README to better fit your specific needs and the unique features of your repository. If you have any questions or need further assistance, don't hesitate to ask!
