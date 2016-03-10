__push() {
	if __check_clean_work_tree; then
		return;
	fi

	current_git_branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p');

	if [ $current_git_branch = "master" ]; then
		printf "${RED}Impossível criar code review na master. Execute codereview help para ajuda.${NC}\n";
		return;
	fi

	git_push_output=$(git push --set-upstream origin $current_git_branch 2>&1);
	if ! [ $? = 0 ]; then
		printf "${RED}Erro ao dar push.${NC}\n";
		echo -n $git_push_output;
		return;
	fi

	__create_pull_request;
}

__create_pull_request() {
	current_git_branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p');
	current_repo=$(git config remote.origin.url 2>&1);
	current_repo_id=${repositories_id["${current_repo}"]};
	
	if __has_active_pull_request_for $current_git_branch; then
		printf "${GREEN}Pull request atualizada com sucesso.${NC}"
	else
		printf "${GREEN}Criando pull request${NC}\n";

		__get_required_input "Título da pull request";
		title=$REPLY
		__get_optional_input "Descrição da pull request";
		description=$REPLY;

		body="{\"sourceRefName\":\"refs/heads/${current_git_branch}\",\"targetRefName\":\"refs/heads/master\",\"title\":\"${title}\",\"description\":\"${description}\"}";
		RESPONSE_HTTP_CODE=$(curl -sw "%{http_code}" -o /dev/null --ntlm -u : -X POST -H "Content-type: application/json; charset=utf-8" ${codereview_base_url_without_project}/_apis/git/repositories/${current_repo_id}/pullrequests?api-version=2.0 -d "${body}");

		if ! [ $RESPONSE_HTTP_CODE = 201 ]; then
			printf "${RED}Erro ao criar pull request.${NC}\n";
			printf "HTTP_CODE: $RESPONSE_HTTP_CODE\n"
			return;
		fi

		printf "${GREEN}Pull request criada com sucesso.${NC}"
	fi
}