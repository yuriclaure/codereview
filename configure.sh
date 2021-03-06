__configure () {
	unset repositories_id;
	unset codereview_base_url_without_project;

	printf "${GREEN}CONFIGURAÇÃO DO CODE-REVIEW.${NC}\n\n";

	__get_required_input "URL do TFS (Exemplo: http://tfs01:8080/tfs/DefaultCollection/Solucoes)";
	codereview_base_url=$REPLY

	username=""
	password=""

	http_response=$(__check_connection $codereview_base_url $username $password);
	while [ $http_response != "200" ]; do
		if [ $http_response = "401" ]; then
			printf "${RED}Não foi possível autenticar${NC}\n";
			printf "Por favor digite suas credenciais do TFS.\n\n";

			__get_required_input "Usuário";
			username=$REPLY
			__get_required_input "Senha";
			password=$REPLY
		else
			printf "${RED}Não foi possivel estabelecer conexão com a URL informada.${NC}\n";
			__get_required_input "Digite a URL do TFS novamente (Exemplo: http://tfs01:8080/tfs/DefaultCollection/Solucoes)";
			codereview_base_url=$REPLY
		fi
		http_response=$(__check_connection $codereview_base_url $username $password);
	done

	echo "# THIS FILE IS AUTO-GENERATED BY configure.sh" > $DIR/settings.sh
	echo "# PLEASE DON'T MODIFY IT" >> $DIR/settings.sh
	echo " " >> $DIR/settings.sh
	echo "codereview_base_url_without_project=\"${codereview_base_url%/*}\"" >> $DIR/settings.sh
	echo "codereview_username=\"${username}\"" >> $DIR/settings.sh
	echo "codereview_password=\"${password}\"" >> $DIR/settings.sh
	echo "" >> $DIR/settings.sh
	echo "declare -A repositories_id;" >> $DIR/settings.sh
	
	json=$(curl --ntlm -u ${codereview_username}:${codereview_password} -X GET $codereview_base_url/_apis/git/repositories?api-version=2.0 2> /dev/null)
	projects=($(echo ${json//[[:blank:]]/} | grep -o "[^\"project\"\:]{\"id\"\:\"[^\"]*\",\"name\"\:\"[^\"]*\""))
	number_of_projects=${#projects[*]}

	i=1;
	for project in "${projects[@]}"
	do
		id=$(echo ${project//[[:blank:]]/} | grep -o -P '(?<=\"id\":\")[^\"]*' -m 1)
		name=$(echo ${project//[[:blank:]]/} | grep -o -P '(?<=\"name\":\")[^\"]*' -m 1)

		printf "${CLEAR}Configurando projeto $i de $number_of_projects do seu TFS.";
		i=$((i+1))

		echo "repositories_id[\"$codereview_base_url/_git/$name\"]=\"$id\"" >> $DIR/settings.sh
	done

	printf "${CLEAR}${GREEN}Projetos do TFS configurados com sucesso.${NC}\n";

	source $DIR/settings.sh;
}