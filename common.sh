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

	changing_to_branch_output=$(git checkout $branch 2>&1);
	if ! [ $? = 0 ]; then
		printf "${RED}Você tem mudanças não comittadas no branch atual.${NC}\n";
		printf "$changing_to_branch_output";
		return 0;
	fi

	return 1;
}

__get_required_input() {
	input_message=$1;

	read -p "$input_message [obrigatório]: " -r;
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

