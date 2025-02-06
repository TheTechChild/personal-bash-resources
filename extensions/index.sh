# Here you can add your own shell extensions, or if you want to follow the patterns of this repository you can just add more .sh files here in extensions and depend on the following code to catch your new shell configurations
## PLEASE NOTE THAT IF YOU CONFIGURE YOUR PATH VARIABLES IN THIS EXTENSIONS FOLDER IT WILL OVERWRITE THE PATH CONFIGURATION FROM THIS REPOSITORY

# Just add a new sh file locally to this extensions folder and the following for loop will add them and run the source command on each of them insuring that they are present in your shell
for file in ./extensions/*.sh; do
  if [ -f "$file" ] && [ "$(basename "$file")" != "index.sh" ]; then
    source "$file"
  fi
done