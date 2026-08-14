# NetworkInterfaces

Protocolos de rede (`HTTPClientProtocol`, `HTTPEndpointProtocol`, `HTTPHeaders`, `NetworkError`, `CancellableProtocol`). Zero dependências locais — não importa nenhum outro module deste repo.

Regra: nada aqui pode importar `Network` (ou qualquer outro module concreto). É a camada que os outros dependem, nunca o contrário.

Testar: `cd Modules/NetworkInterfaces && swift test` — funciona direto, sem Xcode.

Convenções gerais (estrutura de teste, hook de lint) estão no `AGENTS.md` da raiz e em `.claude/CODE_RULES/00-overview.md`.
