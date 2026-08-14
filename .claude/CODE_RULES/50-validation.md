# Regras de Validação

Depois de alterar qualquer arquivo Swift, execute `Scripts/on-write-code-check.sh <arquivo>`. O script falha quando o lint ou o test target iOS do módulo falha. Para validar todas as suítes antes de entregar, rode `Scripts/on-write-code-check.sh` sem argumentos.

O hook executa o target de teste iOS do módulo afetado. Sem argumento, executa o scheme agregador `AllTests`, que roda todos os test targets e coleta coverage.

Depois da validação, revise o índice e os documentos de regras que o hook exibir para o contexto do arquivo alterado.
