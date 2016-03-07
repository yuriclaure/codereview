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

	__remove_accents_from_reply;
}

__get_optional_input() {
	input_message=$1;

	read -p "$input_message [opcional]: " -r;
	if [ -z "$REPLY" ]; then
		REPLY=""
	fi

	__remove_accents_from_reply;
}

__remove_accents_from_reply() {
	REPLY=$(echo $REPLY | iconv -f utf-8 -t ascii//TRANSLIT);
}

__require_clean_work_tree() {
    # Update the index
    git update-index -q --ignore-submodules --refresh
    err=0

    # Disallow unstaged changes in the working tree
    if ! git diff-files --quiet --ignore-submodules --
    then
        printf "${RED}Erro: você tem alterações não commitadas${NC}\n"
        git diff-files --name-status -r --ignore-submodules -- >&2
        err=1
    fi

    # Disallow uncommitted changes in the index
    if ! git diff-index --cached --quiet HEAD --ignore-submodules --
    then
        printf "${RED}Erro: você tem alterações não commitadas${NC}\n"
        git diff-index --cached --name-status -r --ignore-submodules HEAD -- >&2
        err=1
    fi

    if [ $err = 1 ]
    then
        echo >&2 "Por favor, faça um commit ou um stash das mudanças antes de continuar"
        return 0;
    fi

    return 1;
}
