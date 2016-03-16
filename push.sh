__push() {
	if __check_git_repo; then
		return
	fi
	
	if __check_clean_work_tree; then
		return;
	fi

	current_git_branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p');

	if [ $current_git_branch = "master" ]; then
		printf "${RED}Impossível criar code review na master.${NC}\n";
		printf "Execute cr help para ajuda.\n";
		return;
	fi

	git_push_output=$(git push --set-upstream origin $current_git_branch 2>&1);
	if ! [ $? = 0 ]; then
		printf "${RED}Erro ao enviar suas alterações ao servidor.${NC}\n";
		echo $git_push_output;
		return;
	fi

	__create_pull_request "$1";
}

__create_pull_request() {
	current_git_branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p');
	current_repo=$(git config remote.origin.url 2>&1);
	current_repo_id=${repositories_id["${current_repo}"]};
	
	if __has_active_pull_request_for $current_git_branch; then
		printf "${GREEN}Code review atualizada com sucesso.${NC}\n";
	else
		if [ -z "$1" ]; then
			__get_required_input "Digite o título da code review";
			__encode_in_utf8 "$REPLY";
		else
			__encode_in_utf8 "$1";
		fi
		title=$REPLY

		printf "${GREEN}Enviando code review...${NC}";

		body="{\"sourceRefName\":\"refs/heads/${current_git_branch}\",\"targetRefName\":\"refs/heads/master\",\"title\":\"${title}\",\"description\":\"${description}\"}";
		RESPONSE_HTTP_CODE=$(curl -sw "%{http_code}" -o /dev/null --ntlm -u ${codereview_username}:${codereview_password} -X POST -H "Content-type: application/json; charset=utf-8" ${codereview_base_url_without_project}/_apis/git/repositories/${current_repo_id}/pullrequests?api-version=2.0 --data "${body}");

		if ! [ $RESPONSE_HTTP_CODE = 201 ]; then
			printf "${CLEAR}${RED}Erro ao criar pull request.${NC}\n";
			printf "HTTP_CODE: $RESPONSE_HTTP_CODE\n"
			return;
		fi

		printf "${CLEAR}${GREEN}Code review enviada com sucesso.${NC}\n";
	fi
}