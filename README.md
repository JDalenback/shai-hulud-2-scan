# Info

This script searches for package.json files and compares them towards a list of packages affected by the shai-hulud 2.0 attack on NPM. The script does not alter any files and does not provide any fixes for infected versions.

## Usage

The script requires that you have bash installed.
Make the script executable: `chmod +x scan-for-shai-hulud.sh`
Run the script from script root folder (the folder containing the script and the `shai-hulud-2-packages.csv` file).
You execute the script by running `./scan-for-shai-hulud.sh`. By default the script will search for package.json files recursively form the `$HOME`env variable.
If you want to start the search for package.json files from another directory specify that as a parameter when running the script as such `./scan-for-shai-hulud.sh <PATH>`.

For example: `./scan-for-shai-hulud.sh ./User/you/app/your-application`.

If you have bash installed in any other path than `/bin/bash` you need to change the `shebang` at the top of the script.
That would be the first line of the script `#!/bin/bash`.
