__codereview_check_options() {
	option=$1

	if [[ $option == "--"* ]];
		then
		if [ $option = "--push" ];
			then
			__codereview_push;
		elif [ $option = "--finish" ]; 
			then
			__codereview_finish;
		elif [ $option = "--help" ];
			then
			__codereview_help;
		else
			printf "${RED}Parametro $option não reconhecido. Veja --help para ajuda.${NC}\n";
		fi
		return 0;
	fi
	return 1;
}