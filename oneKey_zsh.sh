#!/bin/bash
#        Author Andy963 
#        repo:
#        install zsh oh-my-zsh by oneKey
#        support ubuntu & centos & macOS
#

install_autojump(){
        # 安装 autojump
        git clone git://github.com/joelthelion/autojump.git /tmp/.autojump && cd /tmp/.autojump
        ./install.py
        rm -rf /tmp/.autojump
}

install_ubuntu(){

        # apt-get install sudo -y
        sudo apt-get update -y
        sudo apt-get install tmux -y
        sudo apt-get install git -y
        sudo apt-get install git -y 
        sudo apt-get install curl -y 
        sudo apt-get install zsh -y

        #optional
        #sudo apt-get install terminator -y 
        sudo apt-get install vim -y 
        sudo apt-get install python-pip -y

        install_autojump
        echo "[!] need to add autojump in ~/.zshrc plugin and logoff manually!"
}


install_centos(){

        sudo yum update -y
        sudo yum install tmux -y
        sudo yum install git -y
        sudo yum install git -y
        sudo yum install curl -y 
        sudo yum install zsh -y

        #optional
        #sudo yum install terminator -y 
        sudo yum install vim -y 
        sudo yum install python-pip -y

        install_autojump
        yum intall autojump-zsh -y  # centos7 只安装autojump是无法全用的
}

install_macOS(){

        # brew needed
        echo "[+] brew install some dependencies..."

        # brew update && brew upgrade
        brew install git
        brew install curl
        brew install zsh
        brew install tmux

        install_autojump
}


install_dependencies(){
        # 根据系统安装
        if [[ "$OSTYPE" == "linux-gnu" ]]; then
            source /etc/os-release
            echo "OS: ", $ID 
                # linux
            if [ $ID == "centos" ]; then
              install_centos
            elif [ $ID == "ubuntu" ]; then
              install_ubuntu
            else
              echo "[!] cannot support your OS. (not centos or ubuntu)"
              exit
            fi 
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            echo "OS: macOS"
            install_macOS
        else
            echo "[!] cannot support your OS. (not linux or macOS)"
            exit
        fi
}


# need to exit manually
install_zsh(){
        echo "##########################"
        echo "请手动输入 exit 让程序继续!"
        echo "##########################"
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
}


config_zshrc(){
        bash_aliases=$(cat ~/.zshrc | grep "~/.bash_aliases")
        if [ -z "$bash_aliases" ];then
          echo "[*] add ~/.bash_aliases in ~/.zshrc"
cat <<EOF  >>~/.zshrc
# add ~/.bash_aliases 
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi
EOF
        else
          echo "[*] ~/.bash_aliases exists in ~/.zshrc"
        fi
}


config_dircolors(){
        # only supported for linux
        if [[ "$OSTYPE" == "darwin"* ]]; then
            return
        fi
        # use dircolors
        echo "[*] add ~/.dircolors in ~/.zshrc"
        dircolors -p > ~/.dircolors
cat <<EOF  >>~/.zshrc
# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi
EOF
}


install_zsh_plugins(){
        # install powerline 字体
        if [ ! -d "$HOME/fonts" ]; then
          git clone https://github.com/powerline/fonts.git --depth=1 $HOME/fonts
          cd fonts/
          ./install.sh
          cd ..
          rm -rf fonts
        else
          echo "fonts folder exists..."
        fi

        # install zsh-autosuggestions
        if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
          git clone git://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
          echo "source ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" >> ~/.zshrc 
        else
          echo "[*] ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions exists..."
        fi

        # install zsh-syntax-highlighting
        if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
          git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
          echo "source ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ~/.zshrc
        else
          echo "[*] ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting exists...."
        fi

}


change_zsh_bash_history(){

cat <<EOF >>~/.zshrc
HISTFILE="\$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
EOF

}

config_change_default_shell(){
        # change zsh to default shell
        sudo chsh -s /bin/zsh
        chsh -s /bin/zsh
}

install_done(){
        echo "[!] need to add autojump in ~/.zshrc plugin and logoff manually!"
        echo "######################################################################"
        echo "在.zshrc中修改"
        echo '修改主题：ZSH_THEME="agnoster"'
        echo "添加刚安装的插件：plugins=(git autojump zsh-autosuggestions zsh-syntax-highlighting)"
        echo "[*] enjoy it!"
        echo "######################################################################"
        /bin/zsh
}

install_dependencies
install_zsh
config_zshrc
config_dircolors
install_zsh_plugins
change_zsh_bash_history
config_change_default_shell
install_done