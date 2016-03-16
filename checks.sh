__check_git_repo() {
	git status &> /dev/null
	if ! [ $? = 0 ]; then
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
		printf "${RED}Você precisa informar o nome da branch com o comando create. Execute cr help para ajuda.${NC}\n";
		return 0;
	fi

	return 1;
}

__check_updates() {
	
	CURRENT_FOLDER="$(pwd)";

	cd $DIR &> /dev/null;
	git remote update &> /dev/null;
	UPDATES=$(git rev-list HEAD...origin/master --count);

	if [ $UPDATES != 0 ]; then
		printf "Atualizando codereview...";

		git pull origin master &> /dev/null
		if [ $? = 0 ]; then
			source $DIR/main.sh;
			printf "${CLEAR}${GREEN}Codereview atualizado com sucesso.${NC}\n";
		else
			printf "${CLEAR}${RED}Erro na atualização do codereview.${NC}\n";
		fi
	fi	

	cd $CURRENT_FOLDER &> /dev/null;
}

__check_clean_work_tree() {
    # Update the index
    git update-index -q --ignore-submodules --refresh
    err=0

    # Disallow unstaged changes in the working tree
    if ! git diff-files --quiet --ignore-submodules --
    then
        printf "${RED}Erro: você tem alterações não commitadas${NC}\n"
        git diff-files --name-status -r --ignore-submodules -- >&2
        err=1
    fi

    # Disallow uncommitted changes in the index
    if ! git diff-index --cached --quiet HEAD --ignore-submodules --
    then
        printf "${RED}Erro: você tem alterações não commitadas${NC}\n"
        git diff-index --cached --name-status -r --ignore-submodules HEAD -- >&2
        err=1
    fi

    if [ $err = 1 ]
    then
        echo >&2 "Por favor, faça um commit ou um stash das mudanças antes de continuar"
        return 0;
    fi

    return 1;
}

__check_connection() {
	base_url=$1
	username=$2
	password=$3

	curl -sw "%{http_code}" -o /dev/null --ntlm -u ${username}:${password} -X GET ${base_url}/_apis/git/repositories?api-version=2.0;
}

__has_active_pull_request_for() {
	current_git_branch=$1;
	current_repo=$(git config remote.origin.url 2>&1);
	current_repo_id=${repositories_id["${current_repo}"]};

	list_of_pull_requests=$(curl --ntlm -u ${codereview_username}:${codereview_password} ${codereview_base_url_without_project}/_apis/git/repositories/${current_repo_id}/pullrequests?api-version=2.0 2> /dev/null);

	printf "$list_of_pull_requests" | grep -q "\"status\":\"active\",[\"[a-zA-Z]*\":.*,]*\"sourceRefName\":\"refs/heads/$current_git_branch\",\"targetRefName\":\"refs/heads/master\"";
	PULL_REQUEST_IS_ACTIVE=$?;

	if [ $PULL_REQUEST_IS_ACTIVE = 0 ]; then
		return 0;
	fi

	return 1;
}

__has_unpushed_commits() {

	commits_not_pushed=$(git cherry 2>&1);

	# if it does not have any commit not pushed.
	if [ -z "$commits_not_pushed" ]; then
		return 1;
	fi

	return 0;
}