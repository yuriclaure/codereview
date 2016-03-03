__create_pull_request() {
	declare -A repositories_id=( 
		["http://tfs01:8080/tfs/DigithoBrasil/Solu%C3%A7%C3%B5es%20em%20Software/_git/Domus-Contemplados"]="e5d33934-6334-4845-ade3-37b255d93dfe" 
		["http://tfs01:8080/tfs/DigithoBrasil/Solu%C3%A7%C3%B5es%20em%20Software/_git/Domus-Inscricao"]="1a92b651-ba36-46e8-8a82-0ba44e953488"
		["http://tfs01:8080/tfs/DigithoBrasil/Solu%C3%A7%C3%B5es%20em%20Software/_git/Domus-Seguranca"]="28dbdb07-0288-4b3b-b3c8-7033335e3634"
		["http://tfs01:8080/tfs/DigithoBrasil/Solu%C3%A7%C3%B5es%20em%20Software/_git/Domus-Selecao"]="7fae0e9d-1c05-4afb-8bf5-789160da6ad7"
		["http://tfs01:8080/tfs/DigithoBrasil/Solu%C3%A7%C3%B5es%20em%20Software/_git/Domus-Alternativo"]="e9e8f20f-8c4a-456d-a704-7fb790bb57ab"
		["http://tfs01:8080/tfs/DigithoBrasil/Solu%C3%A7%C3%B5es%20em%20Software/_git/Domus-Administracao"]="53aac979-9e6c-4365-8139-d304d0d7570d"
		["http://tfs01:8080/tfs/DigithoBrasil/Solu%C3%A7%C3%B5es%20em%20Software/_git/Domus-Tramitacao"]="ae71aaba-a768-48a9-b68a-ed4a7bf4b4d6"
		["http://tfs01:8080/tfs/DigithoBrasil/Solu%C3%A7%C3%B5es%20em%20Software/_git/Enderecos"]="c7eb0744-0bd6-455c-bbaa-f426cd8f2801"
	)

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
