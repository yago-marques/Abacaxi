# Recipe

Módulo de domínio de produto para criação e histórico de receitas. As telas deste módulo são SwiftUI; `RecipeModuleFactory` é a única entrada pública e retorna `CoordinatorProtocol`. Mantenha `Creation/` como subfluxo interno e não importe módulos de tela, Persistence ou Data concretos.

Teste regras de ViewModel com Swift Testing (`import Testing`, `@Test`, `#expect`). Use `@testable import Recipe` para acessar detalhes internos, sem ampliar a API pública.
