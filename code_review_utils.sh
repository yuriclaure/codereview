__codereview_reset_master() {
	current_git_branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p');

	if ! [ $current_git_branch = "master" ];
		then
		git checkout master &> /dev/null;
		git fetch origin &> /dev/null
		git reset --hard origin/master &> /dev/null
		git checkout $current_git_branch &> /dev/null;
	fi
}

__codereview_move_to_branch() {
	branch=$1

	changing_to_branch_output=$(git checkout $branch 2>&1);
	if ! [ $? = 0 ];
		then
		printf "${RED}Você tem mudanças não comittadas no branch atual.${NC}\n";
		printf "$changing_to_branch_output";
		return 0;
	fi

	return 1;
}

__codereview_check_git_repo() {
	git status &> /dev/null
	if ! [ $? = 0 ];
		then
		printf "${RED}Você não está em um repositorio git.${NC}\n";
		return 0;
	fi

	return 1;
}

__codereview_check_parameters() {
	if [ $# -gt 2 ];
		then
		printf "${RED}Número de parametros incompatível. Veja --help para ajuda.${NC}\n";
		return 0;
	elif [ $# = 2 ];
		then
		if ! [ $2 = "--push" ];
			then
			printf "${RED}Parametro $2 não reconhecido. Veja --help para ajuda.${NC}\n";
			return 0;
		fi
	elif [ $# = 0 ];
		then
		printf "${RED}Número de parametros incompatível. Veja --help para ajuda.${NC}\n";
		return 0;
	fi

	if [[ "$1" ==  "--"* ]];
		then
		if ! [ $# = 1 ];
			then
			printf "${RED}Número de parametros incompatível. Veja --help para ajuda.${NC}\n";
			return 0;
		fi
	fi

	return 1;
}