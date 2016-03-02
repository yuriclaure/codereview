__codereview_finish() {
	current_git_branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p');

	if [ $current_git_branch = "master" ];
		then
		printf "${RED}Você não pode finalizar code reviews na master.${NC}";
		return;
	fi

	printf "Finalizar essa code review ira deletar essa branch e irá descartar as mudanças que nao foram merged na master.\n";
	read -p "Você tem certeza que quer fazer isso [Y/N]? " -n 1 -r;
	echo " "
	if [[ ! $REPLY =~ ^[Yy]$ ]];
	then
	    return;
	fi

	git fetch origin &> /dev/null
	git reset --hard origin/$current_git_branch &> /dev/null
	git checkout master &> /dev/null
	git pull &> /dev/null
	git branch -D $current_git_branch &> /dev/null

	printf "\n${GREEN}Code review de ${current_git_branch} finalizada.";
}