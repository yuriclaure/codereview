RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
CLEAR='\33[2K\r'

__reset_master() {
	current_git_branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p');

	if ! [ $current_git_branch = "master" ]; then
		git checkout master &> /dev/null;
		git fetch origin &> /dev/null
		git reset --hard origin/master &> /dev/null
		git checkout $current_git_branch &> /dev/null;
	fi
}

__move_to_branch() {
	branch=$1

	git checkout $branch 2>&1;
	if ! [ $? = 0 ]; then
		printf "${RED}Erro: você tem alterações não commitadas${NC}\n";
		printf "Por favor, faça um commit ou um stash das mudanças antes de continuar\n";
		return 0;
	fi

	return 1;
}

__get_required_input() {
	input_message=$1;

	read -p "$input_message: " -r;
	while [ -z "$REPLY" ]; do
		read -p "$input_message [obrigatório]: " -r;
	done
}

__get_optional_input() {
	input_message=$1;

	read -p "$input_message [opcional]: " -r;
	if [ -z "$REPLY" ]; then
		REPLY=""
	fi
}

__encode_in_utf8() {
	SOURCE=$1
	REPLY=$(printf "$SOURCE" | iconv --from-code=ISO-8859-1 --to-code=UTF-8);
}

