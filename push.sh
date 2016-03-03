__push() {
	current_git_branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p');

	if [ $current_git_branch = "master" ];
		then
		printf "${RED}Impossível criar code review na master. Execute codereview help para ajuda.${NC}\n";
		return;
	fi

	git_push_output=$(git push --set-upstream origin $current_git_branch 2>&1);
	if ! [ $? = 0 ];
		then
		printf "${RED}Erro ao dar push.${NC}\n";
		echo -n $git_push_output;
		return;
	fi

	__create_pull_request;
}

__create_pull_request() {
	current_git_branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p');
	current_repo=$(git config remote.origin.url 2>&1)
	current_repo_id=${repositories_id["${current_repo}"]}

	list_of_pull_requests=$(curl --ntlm -u : http://tfs01:8080/tfs/DigithoBrasil/_apis/git/repositories/${current_repo_id}/pullrequests?api-version=2.0 2> /dev/null)

	# if there is already an active pull request for the same branch
	printf "$list_of_pull_requests" | grep -q "\"sourceRefName\":\"refs/heads/$current_git_branch\",\"targetRefName\":\"refs/heads/master\""
	if [ $? = 0 ]; 
		then
			printf "${GREEN}Pull request atualizada com sucesso.${NC}"
	else
		printf "${GREEN}Criando pull request${NC}\n";

		read -p "Título da pull request: " -r;
		title=$REPLY
		read -p "Descrição da pull request: " -r;
		description=$REPLY

		create_pull_request_output=$(curl --ntlm -u : -X POST -i -H "Content-type: application/json" -X POST http://tfs01:8080/tfs/DigithoBrasil/_apis/git/repositories/${current_repo_id}/pullrequests?api-version=2.0 -d "
		    {
		        \"sourceRefName\":\"refs/heads/${current_git_branch}\",
		        \"targetRefName\":\"refs/heads/master\",
		        \"title\":\"${title}\",
		        \"description\":\"${description}\"
		    }" 2> /dev/null);

		if ! [ $? = 0 ];
			then
			printf "${GREEN}Erro ao criar pull request.${NC}\n";
			printf "$create_pull_request_output";
			return;
		fi


		printf "${GREEN}Pull request criada com sucesso.${NC}"
	fi
}