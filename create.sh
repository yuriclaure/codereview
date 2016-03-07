__create() {
	if __check_clean_work_tree; then
		return;
	fi
	
	name_of_work=$1;
	current_git_branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p');

	# switching to master before creating new branch
	if ! [ $current_git_branch = "master" ]; then
		if __move_to_branch master; then
			return
		fi
	fi

	# pulling master to create new branch up-to-date.
	pulling_master_output=$(git pull 2>&1);
	if ! [ $? = 0 ]; then
		printf "${RED}Conflitos ao atualizar master.${NC}\n";
		printf "$changing_to_master_output";
		return;
	fi

	# if branch already exists we try to merge master into it.
	git show-branch $name_of_work &> /dev/null;
	if [ $? = 0 ]; then

		# ask for user confirmation
		printf "${RED}Uma branch com o nome de $name_of_work já existe!${NC}\n${NC}";
		read -p "Você deseja realizar um merge da master nessa branch [Y/N]? " -n 1 -r;
		echo " "
		if [[ ! $REPLY =~ ^[Yy]$ ]]; then
		    return;
		fi

		if __move_to_branch $name_of_work; then
			return
		fi

		# merge master into it, and if it succeeds, reset master.
		git merge master
		if [ $? = 0 ]; then
			__reset_master;
		else
			return;
		fi
	# if branch doesn't exists, we create a new one from master and reset master.
	else
		# create new branch
		git branch $name_of_work &> /dev/null;
		if __move_to_branch $name_of_work; then
			return
		fi

		__reset_master;
	fi

	printf "${GREEN}Branch criada e pronta para ser usada para a code review. \nExecute ${RED}codereview push${GREEN} quando estiver pronto.${NC}\n";
}