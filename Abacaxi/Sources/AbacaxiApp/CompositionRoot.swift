import GeneralInterfaces

enum CompositionRoot {
    static func makeAppCoordinator() -> AppCoordinator {
        let useCaseContainer = UseCaseContainer()
        LauncherModule.registerDependencies(in: useCaseContainer)
        HomeModule.registerDependencies(in: useCaseContainer)
        RecipeModule.registerDependencies(in: useCaseContainer)

        return AppCoordinator(
            makeLauncherCoordinator: { navigationController, onFinish in
                LauncherModule.makeCoordinator(
                    navigationController: navigationController,
                    useCaseContainer: useCaseContainer,
                    onFinish: onFinish
                )
            },
            makeHomeCoordinator: { navigationController in
                HomeModule.start(
                    navigationController: navigationController,
                    useCaseContainer: useCaseContainer
                )
            }
        )
    }
}
