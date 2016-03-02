<h1>Code review TFS</h1>

<h2>Instalação</h2>
Clone esse repositorio em algum lugar da sua maquina, e adicione no seu .bash_profile a seguinte linha:

<code>source <directory>/codereview/code_review_commands.sh</code>

<h2>Comandos</h2>

<code>codereview <branch_name> [--push]</code>

        Cria (ou altera) uma branch a partir da master com o nome <branch_name>
        preparada pra criar um pull request.
        Se a master tiver commits, eles são movidos para essa nova branch e removidos
        da master.
        Se voce adicionar <code>--push</code> já são executadas as ações listadas no comando abaixo.

<code>codereview --push</code>

        Envia os commits na branch atual para o servidor e cria um pull request (ou atualiza um existente) para master.

<code>codereview --finish</code>

        Finaliza o code review deletando a branch atual e voltando para a master.
