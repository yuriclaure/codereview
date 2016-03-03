RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source $DIR/checks.sh
source $DIR/common.sh
source $DIR/config.sh
source $DIR/core.sh
source $DIR/create.sh
source $DIR/finish.sh
source $DIR/help.sh
source $DIR/push.sh
source $DIR/route.sh

alias codereview=__codereview
alias cr=__codereview