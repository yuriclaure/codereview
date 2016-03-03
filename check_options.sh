__check_options() {
	option=$1

	if [[ $option == "--"* ]];
		then
		if [ $option = "--push" ];
			then
			__push;
		elif [ $option = "--finish" ]; 
			then
			__finish;
		elif [ $option = "--help" ];
			then
			__help;
		else
			printf "${RED}Parametro $option não reconhecido. Veja --help para ajuda.${NC}\n";
		fi
		return 0;
	fi
	return 1;
}