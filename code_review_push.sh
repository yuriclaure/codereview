__codereview_push() {
	current_git_branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p');

	if [ $current_git_branch = "master" ];
		then
		printf "${RED}Impossível criar code review na master. Veja --help para ajuda.${NC}\n";
		return;
	fi

	git_push_output=$(git push --set-upstream origin $current_git_branch 2>&1);
	if ! [ $? = 0 ];
		then
		printf "${RED}Erro ao dar push.${NC}\n";
		echo -n $git_push_output;
		return;
	fi

	__codereview_create_pull_request;
}