# Personal Bash Resources

Welcome to the **Personal Bash Resources** repository! This collection of bash functions and resources is designed to automate and simplify a wide variety of tasks, making your programming and daily activities more efficient.

## Overview

This repository includes a diverse set of bash scripts and functions that can help with:

- **Media Manipulation**: Automate tasks like converting, resizing, or organizing media files.
- **Internet Content Downloading**: Easily download content from the web, including videos, images, and documents.
- **File and Directory Management**: Simplify tasks such as renaming, moving, or organizing files and directories.
- **Development Environment Setup**: Set up development environment for different languages

### Original Purpose

The original purpose of this repository was to provide an easy way to package up my shell environment and move it between computers. This allows for seamless uploading of the configuration to a repository or cloud storage, enabling easy retrieval and setup on another computer later. This approach ensures consistency and efficiency across different working environments and computers, since working in tech basically ensures that you are going to be laid off many times as companies shrink and expand.

### Getting Started

**Please note that this repository is designed for MacOS and Linux** - There are no plans to adapt these for Windows usage.

If you use a .bashrc or some other shell configuration for your shell then you will need to substitute the appropriate shell configuration filename in the following commands: `.zshrc` becomes `.bashrc`

1. Clone the repository to your home directory:
   ```
   git clone https://github.com/TheTechChild/personal-bash-resources.git $HOME/personal-bash-resources
   ```

2. Add the following line to your `.bashrc` or `.zshrc`:
   ```
   echo "source $HOME/personal-bash-resources/main.sh" >> ~/.zshrc
   ```

3. Reload your shell configuration:
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