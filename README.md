```bash
# Choose scripts to be installed 
export toBeInstalled="alwaysSudo common uptodate"

sudo apt install curl
cd /tmp && mkdir ubuntu-quicker-scripts && cd ubuntu-quicker-scripts

curl -s https://raw.githubusercontent.com/shellkjell/ubuntu-quicker-scripts/master/install.sh > install.sh && \
curl -s https://raw.githubusercontent.com/shellkjell/ubuntu-quicker-scripts/master/uninstall.sh > uninstall.sh && \
curl -s https://raw.githubusercontent.com/shellkjell/ubuntu-quicker-scripts/master/.bash_aliases > .bash_aliases
 
mkdir scripts && cd scripts

set -f
toBeInstalledArray=($toBeInstalled)
set +f
for script in "${toBeInstalledArray[@]}"; do
   curl -s https://raw.githubusercontent.com/shellkjell/ubuntu-quicker-scripts/master/scripts/"$script".sh > "$script".sh; 
done

cd .. && ./install.sh
```
