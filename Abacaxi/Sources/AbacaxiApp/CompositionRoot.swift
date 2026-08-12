import GeneralInterfaces

enum CompositionRoot {
    static func makeAppCoordinator() -> AppCoordinator {
        let useCaseContainer = UseCaseContainer()
        LauncherModule.registerDependencies(in: useCaseContainer)
        HomeModule.registerDependencies(in: useCaseContainer)

        return AppCoordinator(
            makeLauncherCoordinator: { navigationController, parent in
                LauncherModule.makeCoordinator(
                    navigationController: navigationController,
                    parent: parent,
                    useCaseContainer: useCaseContainer
                )
            },
            makeHomeCoordinator: { navigationController, parent in
                HomeModule.makeCoordinator(
                    navigationController: navigationController,
                    parent: parent,
                    useCaseContainer: useCaseContainer
                )
            }
        )
    }
}
