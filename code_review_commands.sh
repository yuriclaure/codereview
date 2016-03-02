RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

__codereview_finish() {
	current_git_branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p');

	if [ $current_git_branch = "master" ];
		then
		printf "${RED}Você não pode finalizar code reviews na master.${NC}";
		return;
	fi

	printf "Finalizar essa code review ira deletar essa branch e irá descartar as mudanças que nao foram merged na master.\n";
	read -p "Você tem certeza que quer fazer isso [Y/N]? " -n 1 -r;
	echo " "
	if [[ ! $REPLY =~ ^[Yy]$ ]];
	then
	    return;
	fi

	git checkout . &> /dev/null
	git checkout master &> /dev/null
	git pull &> /dev/null
	git branch -d $current_git_branch &> /dev/null

	printf "\n${GREEN}Code review de ${current_git_branch} finalizada.";
}

__codereview_help() {
	printf "codereview <branch_name> [--push]\n\n"
	printf "\tCria (ou altera) uma branch a partir da master com o nome <branch_name> preparada pra criar um pull request.\n"
	printf "\tSe a master tiver commits, eles são movidos para essa nova branch e removidos da master.\n"
	printf "\tSe voce adicionar --push já são executadas as ações listadas no comando abaixo.\n\n"
	printf "codereview --push\n\n"
	printf "\tEnvia os commits na branch atual para o servidor e cria um pull request (ou atualiza um existente) para master.\n\n"
	printf "codereview --finish\n\n"
	printf "\tFinaliza o code review deletando a branch atual e voltando para a master.\n"
	return;
}


__codereview_create_pull_request() {
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

__codereview_push_and_create() {
	current_git_branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p');

	if [ $current_git_branch = "master" ];
		then
		printf "${RED}Impossível criar code review na master. Veja --help para ajuda.${NC}\n";
		return;
	fi

	git_push_output=$(git push --set-upstream origin ${current_git_branch} 2>&1);
	if ! [ $? = 0 ];
		then
		printf "${RED}Você tem mudanças não comittadas no branch atual.${NC}\n";
		printf "$git_push_output";
		return;
	fi

	__codereview_create_pull_request;

}

__codereview_check_options() {
	option=$1

	if [ $option = "--push" ];
		then
		__codereview_push_and_create;
	elif [ $option = "--finish" ]; 
		then
		__codereview_finish;
	elif [ $option = "--help" ];
		then
		__codereview_help;
	else
		printf "${RED}Parametro $option não reconhecido. Veja --help para ajuda.${NC}\n";
		return;
	fi
}

__codereview() {

	git status &> /dev/null
	if ! [ $? = 0 ];
		then
		printf "${RED}Você não está em um repositorio git.${NC}\n";
		return;
	fi

	if [ -z "$1" ];
		then
		echo "Você precisa informar o nome da branch para onde a code review será instanciada. Exemplo:";
		printf "\n\tcodereview novo_botao\n\n";
		printf "Veja --help para mais ajuda.";
		return;
	fi

	if [[ "$1" ==  "--"* ]];
		then
			if [ $# = 1 ];
				then
				__codereview_check_options $1;
			else
				printf "${RED}Número de parametros incompatível. Veja --help para ajuda.${NC}\n";
			fi
		return;
	fi

	should_it_push=false;

	if [ $# -gt 2 ];
		then
		printf "${RED}Número de parametros incompatível. Veja --help para ajuda.${NC}\n";
		return;
	elif [ $# = 2 ];
		then
		if [ $2 = "--push" ];
			then
			should_it_push=true;
		else
			printf "${RED}Parametro $2 não reconhecido. Veja --help para ajuda.${NC}\n";
			return;
		fi
	fi

	name_of_work=$1;
	current_git_branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p');


	# switching to master before creating new branch
	if ! [ $current_git_branch = "master" ];
		then
		changing_to_master_output=$(git checkout master 2>&1);
		if ! [ $? = 0 ];
			then
			printf "${RED}Você tem mudanças não comittadas no branch atual.${NC}\n";
			printf "$changing_to_master_output";
			return;
		fi
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

		changing_to_work_branch_output=$(git checkout $name_of_work 2>&1);
		if ! [ $? = 0 ];
			then
			printf "${RED}Você tem mudanças não comittadas no branch atual.${NC}\n";
			printf "$changing_to_work_branch_output";
			return;
		fi
		git merge master
		if [ $? = 0 ];
			then
			git checkout master &> /dev/null
			git fetch origin &> /dev/null
			git reset --hard origin/master &> /dev/null
			git checkout $name_of_work &> /dev/null
			return;
		fi
	else
		git branch $name_of_work &> /dev/null;
		git checkout $name_of_work &> /dev/null;
		git checkout master &> /dev/null;
		git fetch origin &> /dev/null
		git reset --hard origin/master &> /dev/null
		git checkout $name_of_work &> /dev/null;
	fi

	if [ $should_it_push = true ];
		then
		__codereview_push_and_create;
	else
		printf "${GREEN}Branch criada e pronta para ser usada para a code review. \nExecute ${RED}codereview --push${GREEN} quando estiver pronto.${NC}";
	fi
}

alias codereview=__codereview