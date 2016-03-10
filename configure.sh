__configure () {
	unset repositories_id;
	unset codereview_base_url_without_project;

	printf "${GREEN}CONFIGURAÇÃO DO CODE-REVIEW.${NC}\n\n";

	__get_required_input "URL do TFS (Exemplo: http://<url-do-tfs>/<collection>/<project>)";
	codereview_base_url=$REPLY

	echo "codereview_base_url_without_project=\"${codereview_base_url%/*}\"" > $DIR/settings.sh
	echo "declare -A repositories_id;" >> $DIR/settings.sh
	
	json=$(curl --ntlm -u : -X GET $codereview_base_url/_apis/git/repositories?api-version=2.0 2> /dev/null)
	projects=($(echo ${json//[[:blank:]]/} | grep -o "[^\"project\"\:]{\"id\"\:\"[^\"]*\",\"name\"\:\"[^\"]*\""))
	number_of_projects=${#projects[*]}

	printf "Incluindo projetos do TFS.\n";
	i=1;

	for project in "${projects[@]}"
	do
		id=$(echo ${project//[[:blank:]]/} | grep -o -P '(?<=\"id\":\")[^\"]*' -m 1)
		name=$(echo ${project//[[:blank:]]/} | grep -o -P '(?<=\"name\":\")[^\"]*' -m 1)

		printf "${CLEAR}Configurando projeto $i de $number_of_projects.";
		i=$((i+1))

		echo "repositories_id[\"$codereview_base_url/_git/$name\"]=\"$id\"" >> $DIR/settings.sh
	done

	printf "${CLEAR}${GREEN}Projetos configurados.${NC}\n";
}