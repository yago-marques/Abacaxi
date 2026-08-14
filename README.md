# Abacaxi

<img width="180" height="180" alt="Abacaxi" src="https://github.com/user-attachments/assets/40342f27-1343-4d34-a791-fb7181661fff" />

**Abacaxi** é um app iOS que transforma ingredientes disponíveis em receitas personalizadas com IA. O usuário informa os ingredientes e suas quantidades, responde a perguntas de contexto e recebe uma receita que pode salvar localmente para consultar depois.

Este repositório é, intencionalmente, mais amplo do que um MVP estrito. Ele foi construído como um objeto de avaliação técnica: a maior superfície de integração permite demonstrar decisões de arquitetura, modularização, persistência, rede, navegação, testabilidade, build e desenvolvimento assistido por IA.

> A complexidade aqui é uma escolha de contexto, não uma prescrição para todo produto pequeno. Em um MVP convencional, parte desta estrutura seria prematura; neste desafio, ela torna explícito como a base poderia evoluir com previsibilidade.

## O produto

- Onboarding de primeiro acesso;
- Consulta de tentativas diárias disponíveis;
- Seleção, remoção e ajuste de quantidade de ingredientes;
- Perguntas para personalizar a geração;
- Geração e visualização de receitas;
- Salvamento manual de receitas favoritas e busca na lista local.

## Arquitetura

O projeto usa módulos Swift locais e contratos explícitos entre camadas. A separação reduz acoplamento acidental e limita o impacto de mudanças, favorecendo um grafo de build mais previsível e uma base mais fácil de navegar por pessoas e ferramentas de IA.

Cada módulo em `Modules/` é um **Swift Package Manager (SPM)** local, com produto, dependências e testes próprios. Além de organizar o código, isso transforma as fronteiras arquiteturais em fronteiras de compilação: cada package pode ser construído e testado isoladamente.

<img width="675" height="521" alt="image" src="https://github.com/user-attachments/assets/faf5d749-cac6-4778-951b-8ce9a00fb3c1" />

As implementações concretas não sobem para as camadas superiores. A apresentação recebe somente Use Cases definidos em `DomainInterfaces`; `Domain` depende dos contratos de `DataInterfaces`; e `Data` implementa repositories usando contratos de persistência e rede.

| Área | Responsabilidade |
| --- | --- |
| `Home` | Feature UIKit com MVVM, onboarding, tentativas e atalhos de receita. |
| `Recipe` | Feature SwiftUI com `NavigationStack`, ingredientes, perguntas, resultado e receitas salvas. |
| `Launcher` | Fluxo inicial e preparação do app. |
| `Domain` / `DomainInterfaces` | Regras de negócio, Use Cases e contratos consumidos pela apresentação. |
| `Data` / `DataInterfaces` | Repositories, mappers e contratos de dados. |
| `Network` / `NetworkInterfaces` | Cliente HTTP e contratos de transporte. |
| `Persistence` / `PersistenceInterfaces` | Implementações e contratos de armazenamento local. |
| `DesignSystem` | Componentes e tokens reutilizáveis para UIKit e SwiftUI. |
| `Extensions` | Facilitadores de constraints, animações e transições. |
| `GeneralInterfaces` | Contratos compartilhados, como coordinator e container de Use Cases. |

### POP no nível de módulo

O desenho privilegia **Protocol-Oriented Programming (POP)** no nível de módulo. Cada feature expõe uma porta de composição pequena e depende de contratos, não de implementações concretas. Os `FeatureModule`s iniciam seus próprios fluxos, factories estáticas montam objetos prontos para uso e builders no app-shell registram as dependências. Coordinators cuidam apenas de navegação; ViewModels concentram decisões de apresentação e regras do fluxo.

Os protocolos descrevem colaborações, implementações permanecem encapsuladas por padrão (`internal`) e o app-shell é o único lugar que conhece o grafo concreto de dependências. Isso permite substituir infraestrutura, criar duplos de teste e evoluir módulos sem propagar tipos concretos pelas camadas superiores.

### SOLID aplicado às fronteiras

Os princípios SOLID orientam a estrutura sem exigir camadas artificiais:

- **Single Responsibility:** features, Use Cases, repositories e stores têm responsabilidades delimitadas;
- **Open/Closed:** novos fluxos e implementações são acrescentados atrás de contratos, com baixo impacto nos consumidores existentes;
- **Liskov Substitution:** implementações de infraestrutura e duplos de teste respeitam os mesmos protocolos;
- **Interface Segregation:** contratos são específicos por contexto, evitando dependências genéricas e inchadas;
- **Dependency Inversion:** Presentation, Domain e Data dependem de interfaces; o app-shell compõe implementações concretas.

SPM torna essas decisões verificáveis no build: dependências indevidas não são apenas convenções, elas aparecem no grafo de packages.

### UIKit e SwiftUI

`Home` foi implementado em UIKit e `Recipe` em SwiftUI

Essa convivência é comum em apps nativos maduros: muitas empresas mantêm UIKit em fluxos estáveis enquanto introduzem SwiftUI em novas funcionalidades, ou estão em uma migração gradual. Ter fronteiras de módulo e contratos bem definidos torna essa transição menos arriscada, pois uma feature pode evoluir de framework sem alterar o domínio, a camada de dados ou os fluxos adjacentes.

### Modelos e mapeamento

Cada fronteira usa o modelo adequado à sua responsabilidade:

- `PresentationModel`: estado e identidade necessários à UI;
- `BusinessModel`: entrada e saída de Use Cases e repositories;
- `RemoteModel`: detalhes privados do contrato HTTP;
- mappers fazem a conversão na fronteira que os consome.

Isso impede que detalhes de transporte ou persistência vazem para a apresentação.

## Infraestrutura nativa, sem dependências externas de runtime

O app privilegia APIs nativas para reduzir custo de manutenção e manter o comportamento sob controle:

- `URLSession` para comunicação HTTP;
- `Core Data` para metadados de receitas salvas;
- armazenamento de imagens em arquivo local, mantendo bytes fora do banco;
- `Keychain` para dados seguros, como o identificador do dispositivo;
- `UserDefaults` para estado leve, como o primeiro acesso;
- `XcodeGen` para gerar o projeto a partir de `project.yml`;
- `SwiftGen` para gerar acesso tipado às strings de cada módulo.

`XcodeGen` e `SwiftGen` são ferramentas de desenvolvimento instaladas localmente; não são dependências de runtime do aplicativo.

## Ambientes

<img width="50" height="50" alt="abacaxi_stage" src="https://github.com/user-attachments/assets/c0ac4753-eebb-4f62-b05e-653b336b5c9c" />
<img width="50" height="50" alt="Abacaxi" src="https://github.com/user-attachments/assets/2d9b916b-aa3e-46f4-9fa9-598f34f8cecf" />


O projeto gera dois targets a partir de `project.yml` e de arquivos `.xcconfig` por ambiente:

| Target | Ambiente | Características |
| --- | --- | --- |
| `Abacaxi` | Production | Bundle principal, App Icon de produção e menu de debug desabilitado. |
| `Abacaxi Stage` | Stage | Bundle com sufixo `.stage`, App Icon próprio, host de stage e menu de debug habilitado. |

Configurações compartilhadas ficam em `Configs/Base.xcconfig` e `Configs/App.xcconfig`; cada target combina esses valores com seu ambiente. Credenciais locais ficam em `Configs/Secrets.xcconfig`, que não é versionado, e o repositório disponibiliza `Configs/Secrets.example.xcconfig` como referência.

## Desenvolvimento orientado por especificação (SDD) e IA

O desafio foi desenvolvido em uma janela curta de **quatro dias úteis**, entre segunda e sexta-feira, em período de contraturno. Esse limite motivou um processo disciplinado de desenvolvimento assistido por IA, não apenas a aceleração da escrita de código.

Mudanças relevantes são discutidas e registradas com OpenSpec em proposta, design, requisitos e tarefas antes da implementação. Modelos de custo-benefício, como **Sonnet**, **GPT-5.6-terra** e **GLM-5.2**, são usados em uma estratégia multi-modelo, escolhida conforme a natureza da atividade.

O repositório continua sendo a fonte de verdade: especificações, contratos entre módulos, regras de código e testes têm precedência sobre qualquer sugestão de modelo.

### Guardrails de qualidade e base de conhecimento

As convenções estão organizadas em `.claude/CODE_RULES/` por domínio — testes, Swift, arquitetura, UIKit e validação. Essa é uma base de conhecimento contextual preparada para evoluir para um grafo de decisões técnicas: hoje ela já possui documentos especializados e roteamento por contexto; relações estruturadas e consultáveis entre decisões ainda seriam uma evolução futura.

`Scripts/on-write-code-check.sh` identifica o tipo do arquivo alterado e apresenta somente as regras relevantes. O mesmo fluxo combina:

- SwiftLint;
- execução do target de teste do módulo afetado;
- revisão contextual das `CODE_RULES`;
- execução abrangente pelo scheme `AllTests`, que centraliza todos os test targets e coleta coverage.

Isso reduz conhecimento implícito e dá feedback verificável a desenvolvedores e agentes de IA. Uma alteração não depende apenas de memória de conversa ou convenções informais: ela é validada localmente contra regras explícitas e testes isolados.

## Como executar

### Pré-requisitos

- macOS com Xcode e um simulador iOS disponível;
- [Homebrew](https://brew.sh).

### Início rápido

Após clonar o repositório, execute na raiz:

```bash
make start
```

O comando:

1. instala XcodeGen e SwiftGen via Homebrew quando estiverem ausentes;
2. valida a versão exigida do XcodeGen (`2.45.3`);
3. gera os acessos tipados de `Localizable.strings` de todos os módulos;
4. gera `Abacaxi.xcodeproj` a partir de `project.yml`;
5. abre o projeto no Xcode.

O `.xcodeproj` e os arquivos gerados pelo SwiftGen não são versionados. Rode `make start` novamente depois de clonar o repositório ou modificar `project.yml` e strings localizadas.

### Comandos úteis

```bash
make generate-localizations # Regenera somente as strings tipadas
make generate               # Regenera o projeto Xcode
make lint                   # Executa o SwiftLint
make lint-strict            # Executa o SwiftLint em modo estrito
```

Cada módulo é um package Swift local e pode ser construído isoladamente:

```bash
cd Modules/Recipe && swift build
```

## Evoluções para escala

As capacidades abaixo são próximos passos — não fazem parte da implementação atual:

- observabilidade mobile com ferramentas como Datadog e Firebase Crashlytics;
- feature flags e remote configuration para rollout gradual e experimentação;
- analytics de produto para entender os funis de criação e salvamento de receitas;
- acessibilidade, com Dynamic Type, VoiceOver, contraste e redução de movimento;
- CI/CD para validação, testes, distribuição e controle de releases;
- Fastlane para automação de assinatura, builds e distribuição.

Em um cenário de milhões de usuários, centenas de desenvolvedores e monorepo, a evolução natural do sistema de build seria o **Bazel**: builds herméticos, cache remoto, execução paralela e maior previsibilidade no tempo de feedback.

## O que avaliar neste projeto

- A direção das dependências e o encapsulamento entre módulos;
- O uso de POP e contratos para proteger as fronteiras entre módulos;
- A separação deliberada entre UIKit e SwiftUI sem perder consistência visual;
- O uso de contratos, factories e builders para montar dependências;
- A estratégia de modelos e mappers entre apresentação, domínio e dados;
- A escolha de ferramentas nativas e a ausência de dependências externas de runtime;
- A reprodutibilidade do build e da geração de código;
- O processo SDD e os guardrails que tornam desenvolvimento com IA mais confiável.
