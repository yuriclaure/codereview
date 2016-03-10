<h1>Code review TFS</h1>

<h2>Instalação</h2>
Clone esse repositorio em algum lugar da sua maquina, e adicione no seu .bash_profile a seguinte linha:

<code>source {installation-directory}/codereview/main.sh</code>

<h2>Configure seus repositórios</h2>

<code>
	declare -A code_review_repositories_id;
	code_review_repositories_id["endereco-do-repositorio"]="id-do-projeto-no-tfs";
</code>

		Você pode achar o <b>endereço do repositório</b> com o comando:

		<code>
			git config remote.origin.url
		</code>

<h2>Comandos</h2>

<code>codereview create \<branch_name\></code>

        Cria (ou altera) uma branch a partir da master com o nome <branch_name>
        preparada pra criar um pull request.
        Se a master tiver commits, eles são movidos para essa nova branch e removidos
        da master.

<code>codereview push</code>

        Envia os commits na branch atual para o servidor e cria um pull request (ou atualiza um existente) para master.

<code>codereview finish</code>

        Finaliza o code review deletando a branch atual e voltando para a master.

<code>codereview help</code>

        Imprime o manual dos comandos disponíveis.
