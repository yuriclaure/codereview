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