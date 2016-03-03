__check_git_repo() {
	git status &> /dev/null
	if ! [ $? = 0 ];
		then
		printf "${RED}Você não está em um repositorio git.${NC}\n";
		return 0;
	fi

	return 1;
}

__check_parameters() {

	if [ $# = 0 ]; then
		__help;
		return 0;
	fi

	command=$1
	if [ "$command" = "create" ] && [ $# -lt 2 ]; then
		printf "${RED}Você precisa informar o nome da branch com o comando create. Execute codereview help para ajuda.${NC}\n";
		return 0;
	fi

	return 1;
}

__check_updates() {
	
	CURRENT_FOLDER="$(pwd)"

	cd $DIR &> /dev/null
	git remote update &> /dev/null
	UPDATES=$(git rev-list HEAD...origin/master --count)
	
	if [ $UPDATES != 0 ]; then
		echo "Iniciando atualização do CodeReview..."

		git pull origin master &> /dev/null

		if [ $? = 0 ]; then
			cd source ~/.bash_profile &> /dev/null
			echo "Fim da atualização do CodeReview."
		else
			echo "Não foi possível atualizar o CodeReview!"
		fi
	fi	

	cd $CURRENT_FOLDER &> /dev/null
}