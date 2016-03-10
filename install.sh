__configure () {
	unset repositories_id;
	unset codereview_base_url_without_project;

	__get_required_input "URL do TFS (Exemplo: http://<url-do-tfs>/<collection>/<project>)";
	codereview_base_url=$REPLY

	echo "codereview_base_url_without_project=\"${codereview_base_url%/*}\"" > $DIR/config.sh
	echo "declare -A repositories_id;" >> $DIR/config.sh
	
	json=$(curl --ntlm -u : -X GET $codereview_base_url/_apis/git/repositories?api-version=2.0 2> /dev/null)
	projects=($(echo ${json//[[:blank:]]/} | grep -o "[^\"project\"\:]{\"id\"\:\"[^\"]*\",\"name\"\:\"[^\"]*\""))
	number_of_projects=${#projects[*]}

	printf "Incluindo projects do TFS.\n";
	i=1;

	for project in "${projects[@]}"
	do
		id=$(echo ${project//[[:blank:]]/} | grep -o -P '(?<=\"id\":\")[^\"]*' -m 1)
		name=$(echo ${project//[[:blank:]]/} | grep -o -P '(?<=\"name\":\")[^\"]*' -m 1)

		printf "${CLEAR}Configurando projeto $i de $number_of_projects.";
		i=$((i+1))

		echo "repositories_id[\"$codereview_base_url/_git/$name\"]=\"$id\"" >> $DIR/config.sh
	done

	printf "${CLEAR}Projetos configurados.";
}


if ! [ -f  $DIR/config.sh ]; then
	__configure;
fi

source $DIR/config.sh