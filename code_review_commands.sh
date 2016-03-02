RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source $DIR/code_review_utils.sh
source $DIR/code_review_finish.sh
source $DIR/code_review_help.sh
source $DIR/code_review_create_pull_request.sh
source $DIR/code_review_push.sh
source $DIR/code_review_check_options.sh
source $DIR/code_review_main.sh

alias codereview=__codereview