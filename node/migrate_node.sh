#!/bin/bash
# This script will make Battle of Slots Vue Project runnable with Node v14.20.1
__cy="\033[1;36m"
__gr="\033[1;32m"
__re="\033[1;31m"
__ye="\033[1;33m"
__bl="\033[1;34m"
__wh="\033[1;37m"
__="\033[0m"

LOGS_PATH='/tmp/nvm_logs'
REQUIRED_NODE_VERSION='v14.20.1'

#Helpers
say() {
    echo -ne "${1}${__}"
}

ask() {
    QUESTION=$(say "\n$1 ${__gr}(y/Y)${__} or ${__re}(n/N)${__}: ")
    ANSWER=""
    YES="([yY]|[yY][eE][sS])"
    NO="([nN]|[nN][oO])"

    while [ -z "$ANSWER" ]; do
        read -p "$QUESTION" ANSWER

        if   [[ $ANSWER =~ $YES ]]; then ANSWER='1'
        elif [[ $ANSWER =~  $NO ]]; then ANSWER='0'
        else
            ANSWER=''
            continue
        fi
    done

    echo "$ANSWER"
}

# Check if Node v14.20.1 on system
check_required_node() {
    CURRENT_VERSION=$(node -v)

    if [ "$CURRENT_VERSION" == "$REQUIRED_NODE_VERSION" ]; then
        echo '1'
    else
        echo '0'
    fi
}

install_node() {
    VERSION=$1

    nvm install "$VERSION" >> $LOGS_PATH 2>&1

    if [ $? != 0 ]; then
        say "\nCheck NVM logs in ${__ye}$LOGS_PATH\n"
    fi
}

use_node() {
    VERSION=$1

    if [ "$VERSION" == '0' ]; then exit 1; fi

    nvm use $VERSION

    MAKE_DEFAULT=$(ask "Make Node $VERSION as default?")

    if [ "$MAKE_DEFAULT" == '1' ]; then
        nvm alias default $VERSION
    fi
}

install_nvm() {
    curl -s -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh | bash >> $LOGS_PATH 2>&1

    if [ -f ~/.profile ]; then
        source ~/.profile
    elif [ -f ~/.bashrc ]; then
        source ~/.bashrc
    else
        say "\n\n${__re}>>> Restart Terminal and run the Script again <<<\n\n"
    fi

}

check_nvm() {
    if [ ! -z $(type -t nvm) ]; then
        echo '1'
    else
        echo '0'
    fi
}

get_required_node() {
    PREFIX='v'
    REQUIRED_NODE=$(nvm list $REQUIRED_NODE_VERSION --no-colors | awk -Fv 'END { print $2 }' | sed 's/*//g')
    if [ -n "$REQUIRED_NODE" ]; then
        echo "$PREFIX$REQUIRED_NODE"
    else
        echo '0'
    fi
}

# # # # # # # # # # # # # # # # # # # # #
if [ ! -f package.json ]; then
    say "\n\n${__re}No Package.json found${__}\nMove the script to root folder of project then execute\n\n"
    exit 1
fi

IS_NODE=$(check_required_node)
if [ "$IS_NODE" == '0' ]; then
    say "\nCurrent version is ${__re}Node $(node -v)\n"
    UPGRADE_NODE=$(ask "Upgrade to Node $REQUIRED_NODE_VERSION?")

    if [ "$UPGRADE_NODE" == '0' ]; then exit 1; fi
fi

IS_NVM_EXISTS=$(check_nvm)
if [ "$IS_NODE" == '0' ] && [ "$IS_NVM_EXISTS" == '0' ]; then
    INSTALL_NVM=$(ask "Install NVM?")

    if [ "$INSTALL_NVM" == '0' ]; then exit 1
    else install_nvm; fi
fi

REQUIRED_NODE=$(get_required_node)
if [ "$IS_NODE" == '0' ] && [ "$REQUIRED_NODE" == '0' ]; then
    INSTALL_NODE=$(ask "Install Node $REQUIRED_NODE_VERSION via NVM?")

    if [ "$INSTALL_NODE" == '0' ]; then
        exit 1
    else
        install_node "$REQUIRED_NODE_VERSION"
        use_node "$REQUIRED_NODE_VERSION"
    fi
fi

if [ "$IS_NODE" == '0' ] && [ "$REQUIRED_NODE" != '0' ]; then
    use_node "$REQUIRED_NODE"
fi

MIGRATE=$(ask "migrate project to?")
if [ "$MIGRATE" == '0' ]; then exit 1; fi

say "\n${__gr}Deleting node_modules ...\n\n"
if [ -d node_modules ]; then
    rm -rf node_modules
fi

say "${__gr}Installing NPM packages ...\n\n"
npm install --unsafe-perm

say "${__gr}Done! you can run the build you wish\n\n"
