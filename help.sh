__help() {
	printf "codereview create <branch_name>\n\n"
	printf "\tCria (ou altera) uma branch a partir da master com o nome <branch_name> preparada pra criar um pull request.\n"
	printf "\tSe a master tiver commits, eles são movidos para essa nova branch e removidos da master.\n\n"
	printf "codereview push\n\n"
	printf "\tEnvia os commits na branch atual para o servidor e cria um pull request (ou atualiza um existente) para master.\n\n"
	printf "codereview finish\n\n"
	printf "\tFinaliza o code review deletando a branch atual e voltando para a master.\n"
	return;
}