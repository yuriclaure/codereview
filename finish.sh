__finish() {
	if __check_clean_work_tree; then
		return;
	fi

	current_git_branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p');

	if [ $current_git_branch = "master" ]; then
		printf "${RED}Você não pode finalizar code reviews na master.${NC}";
		return;
	fi

	if __has_active_pull_request_for $current_git_branch; then
		printf "${RED}Não foi possivel finalizar codereview.${NC}\n";
		printf "Você possui uma pull request ainda ativa nessa branch, aprove ou rejeite para continuar."
		return;
	fi

	if __has_unpushed_commits; then
		printf "${RED}Você tem commits não enviados ao branch remoto, essa ação irá descartar todas essas mudanças.${NC}\n";
	else
		printf "Você irá finalizar essa branch e voltar para a master.\n";
	fi

	read -p "Você tem certeza que quer fazer isso [y/n]? " -n 1 -r;
	echo " "
	if [[ ! $REPLY =~ ^[Yy]$ ]]; then
	    return;
	fi

	git fetch origin &> /dev/null
	git reset --hard origin/$current_git_branch &> /dev/null
	git checkout master &> /dev/null
	git pull &> /dev/null
	git branch -D $current_git_branch &> /dev/null

	printf "\n${GREEN}Code review de ${current_git_branch} finalizada.";
}