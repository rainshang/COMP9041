alias airbnb='python3 ~/Desktop/9900/manage.py runserver 0:8007'

export CLICOLOR=1
export LSCOLORS=gxfxcxdxbxegedabagacad
export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;36m\]\w\[\033[00m\]\$ '
export GREP_OPTIONS='--color=auto'
export LS_OPTIONS='--color=auto'
alias ls='ls $LS_OPTIONS'


function llegit() {
    /home/cs2041/bin/legit "$@"
}
