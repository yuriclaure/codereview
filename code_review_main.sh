__codereview() {

	if __codereview_check_git_repo;
		then
		return
	fi

	if __codereview_check_parameters $@;
		then
		return
	fi

	if __codereview_check_options $1;
		then
		return
	fi

	if [ $# = 2 ] && [ $2 = "--push" ];
		then
		should_it_push=true;
	else
		should_it_push=false;
	fi

	name_of_work=$1;
	current_git_branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p');

	# switching to master before creating new branch
	if ! [ $current_git_branch = "master" ];
		then
		if __codereview_move_to_branch master;
			then
			return
		fi
	fi

	pulling_master_output=$(git pull 2>&1);
	if ! [ $? = 0 ];
		then
		printf "${RED}Conflitos ao atualizar master.${NC}\n";
		printf "$changing_to_master_output";
		return;
	fi

	# if branch already exists
	git show-branch $name_of_work &> /dev/null;
	if [ $? = 0 ];
		then
		printf "${RED}Uma branch com o nome de $name_of_work já existe!${NC}\n${NC}";
		read -p "Você deseja realizar um merge da master nessa branch [Y/N]? " -n 1 -r;
		echo " "
		if [[ ! $REPLY =~ ^[Yy]$ ]];
		then
		    return;
		fi

		if __codereview_move_to_branch $name_of_work;
			then
			return
		fi

		git merge master
		if [ $? = 0 ];
			then
			__codereview_reset_master;
		else
			return;
		fi
	else
		git branch $name_of_work &> /dev/null;
		if __codereview_move_to_branch $name_of_work;
			then
			return
		fi

		__codereview_reset_master;
	fi

	if [ $should_it_push = true ];
		then
		__codereview_push;
	else
		printf "${GREEN}Branch criada e pronta para ser usada para a code review. \nExecute ${RED}codereview --push${GREEN} quando estiver pronto.${NC}\n";
	fi
}