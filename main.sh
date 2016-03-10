DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source $DIR/checks.sh
source $DIR/common.sh
source $DIR/configure.sh
source $DIR/core.sh
source $DIR/create.sh
source $DIR/finish.sh
source $DIR/help.sh
source $DIR/push.sh
source $DIR/route.sh

if ! [ -f $DIR/settings.sh ]; then
	__configure;
fi
source $DIR/settings.sh

alias codereview=__codereview
alias cr=__codereview