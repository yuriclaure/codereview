RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source $DIR/check_updates.sh
source $DIR/utils.sh
source $DIR/finish.sh
source $DIR/help.sh
source $DIR/create_pull_request.sh
source $DIR/push.sh
source $DIR/check_options.sh
source $DIR/core.sh

alias codereview=__codereview