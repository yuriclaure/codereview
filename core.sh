__codereview() {

	printf "${RED}Você está usando uma versão desativada desse projeto, acesse: https://github.com/yuriclaure/tfs-pullrequest.${NC}\n";

	__check_updates;

	if __check_parameters "$@"; then
		return
	fi

	__route "$@";
}