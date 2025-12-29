# Arena_Personal
A repo to house my personal code for the arena material. 

## Install Conda and Arena
```
mkdir -p ~/miniconda3
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
rm ~/miniconda3/miniconda.sh

source ~/miniconda3/bin/activate

conda init --all

git clone https://github.com/callummcdougall/ARENA_3.0.git

ARENA_3.0/install.sh

conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main

conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r

ARENA_3.0/install.sh
```

