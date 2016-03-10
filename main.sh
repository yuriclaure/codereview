DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source $DIR/checks.sh
source $DIR/common.sh
source $DIR/core.sh
source $DIR/create.sh
source $DIR/finish.sh
source $DIR/help.sh
source $DIR/install.sh
source $DIR/push.sh
source $DIR/route.sh

alias codereview=__codereview
alias cr=__codereview