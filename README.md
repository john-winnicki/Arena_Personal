# Arena_Personal
A repo to house my personal code for the arena material. 

## Install Arena material and required packages.
```
pip install -r requirements_arena_ch1_runpod_modern.txt

git clone https://github.com/callummcdougall/ARENA_3.0.git
```

# Fixing SSH and Github
After creating your ssh arena_key, do the following. 
## On Local Desktop
```
ssh-add -l || true
ssh-add ~/.ssh/arena_key
ssh-add -l

ssh -A root@213.173.102.5 -p 12214 -i ~/.ssh/arena_key
```
## Once SSH'd in
```
ssh-add -l
ssh -T git@github.com
```