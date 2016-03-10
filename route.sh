__route() {
	command=$1;

	if [ $command = "create" ]; then
		branch_name=$2;
		__create $branch_name;
	elif [ $command = "push" ]; then
		__push;
	elif [ $command = "finish" ]; then
		__finish;
	elif [ $command = "help" ]; then
		__help;
	elif [ $command = "configure"]; then
		__configure;
	else
		printf "${RED}Parametro $command não reconhecido. Execute codereview help para ajuda.${NC}\n";
	fi
}