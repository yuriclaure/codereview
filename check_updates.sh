__check_updates() {
	
	UPDATES=$(git rev-list HEAD...origin/master --count)
	CURRENT_FOLDER="$(pwd)"
	
	if [ $UPDATES != 0 ]
		then
			echo "Iniciando atualização do CodeReview..."

			cd $DIR &> /dev/null

			git pull origin master &> /dev/null
			PULL_EXIT_CODE=$?

			cd $CURRENT_FOLDER &> /dev/null

			if ! [ $PULL_EXIT_CODE = 0 ]
				then
					echo "Não foi possível atualizar o CodeReview!"
					return
				fi

			cd source ~/.bash_profile &> /dev/null

			echo "Fim da atualização do CodeReview."
		fi	

	return $UPDATES;
}