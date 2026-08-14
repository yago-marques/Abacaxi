import CoreData
import UIKit

/// A window that presents a minimal debug menu on a shake gesture.
///
/// Installed by `SceneDelegate` only when `DebugMenuConfiguration.isEnabled` is
/// true (Stage builds); the flag is re-checked on every shake so a build with
/// `ENABLE_DEBUG_MENU = NO` never reacts to the gesture.
final class DebugMenuWindow: UIWindow {
    private let configuration: DebugMenuConfiguration

    init(windowScene: UIWindowScene, configuration: DebugMenuConfiguration = DebugMenuConfiguration()) {
        self.configuration = configuration
        super.init(windowScene: windowScene)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("DebugMenuWindow does not support Interface Builder")
    }

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        guard motion == .motionShake, configuration.isEnabled else {
            super.motionEnded(motion, with: event)
            return
        }

        presentDebugMenu()
    }
}

private extension DebugMenuWindow {
    var apiBaseURL: String {
        // Same Info.plist key NetworkConfiguration.fromInfoPlist reads, so the
        // menu shows exactly the host the app resolves at runtime.
        Bundle.main.object(forInfoDictionaryKey: "APIBaseURL") as? String ?? "indisponível"
    }

    var topPresenter: UIViewController? {
        var presenter = rootViewController
        while let presented = presenter?.presentedViewController {
            presenter = presented
        }
        return presenter
    }

    func presentDebugMenu() {
        guard let presenter = topPresenter, !(presenter is UIAlertController) else { return }

        let bundleIdentifier = Bundle.main.bundleIdentifier ?? "indisponível"
        let alert = UIAlertController(
            title: "Debug",
            message: "Ambiente: \(bundleIdentifier)\nAPI: \(apiBaseURL)",
            preferredStyle: .actionSheet
        )
        alert.addAction(
            UIAlertAction(title: "Limpar dados locais", style: .destructive) { [weak self] _ in
                self?.clearLocalData()
            }
        )
        alert.addAction(UIAlertAction(title: "Fechar", style: .cancel))
        if let popover = alert.popoverPresentationController {
            let bounds = presenter.view.bounds
            popover.sourceView = presenter.view
            popover.sourceRect = CGRect(x: bounds.midX, y: bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        presenter.present(alert, animated: true)
    }

    func clearLocalData() {
        var cleared: [String] = []
        var failures: [String] = []

        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            // UserDefaultsStore uses UserDefaults.standard, whose persistent
            // domain is the main bundle identifier.
            UserDefaults.standard.removePersistentDomain(forName: bundleIdentifier)
            cleared.append("UserDefaults (onboarding e preferências)")
        } else {
            failures.append("UserDefaults")
        }

        clearRecipeImages(cleared: &cleared, failures: &failures)
        clearSavedRecipesDatabase(cleared: &cleared, failures: &failures)
        presentClearResult(cleared: cleared, failures: failures)
    }

    func clearRecipeImages(cleared: inout [String], failures: inout [String]) {
        // Same location RecipeImageStore uses: Documents/RecipeImages.
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            failures.append("Imagens de receitas")
            return
        }

        let imagesURL = documentsURL.appendingPathComponent("RecipeImages", isDirectory: true)
        guard fileManager.fileExists(atPath: imagesURL.path) else {
            cleared.append("Imagens de receitas (já vazio)")
            return
        }

        do {
            try fileManager.removeItem(at: imagesURL)
            cleared.append("Imagens de receitas (Documents/RecipeImages)")
        } catch {
            failures.append("Imagens de receitas")
        }
    }

    func clearSavedRecipesDatabase(cleared: inout [String], failures: inout [String]) {
        // SavedRecipeStoreBuilder loads NSPersistentContainer(name: "SavedRecipes")
        // at the default store location (Library/Application Support).
        let fileManager = FileManager.default
        let storeURL = NSPersistentContainer.defaultDirectoryURL()
            .appendingPathComponent("SavedRecipes.sqlite")
        let storeFileURLs = [
            storeURL,
            URL(fileURLWithPath: storeURL.path + "-wal"),
            URL(fileURLWithPath: storeURL.path + "-shm")
        ]

        var failed = false
        for fileURL in storeFileURLs where fileManager.fileExists(atPath: fileURL.path) {
            do {
                try fileManager.removeItem(at: fileURL)
            } catch {
                failed = true
            }
        }

        if failed {
            failures.append("Banco de receitas salvas")
        } else {
            cleared.append("Banco de receitas salvas (SavedRecipes.sqlite)")
        }
    }

    func presentClearResult(cleared: [String], failures: [String]) {
        var lines = ["Limpou:"] + cleared.map { "• \($0)" }
        if !failures.isEmpty {
            lines.append("Falhou:")
            lines.append(contentsOf: failures.map { "• \($0)" })
        }
        lines.append("\nReinicie o app para aplicar.")

        let alert = UIAlertController(
            title: "Dados locais limpos",
            message: lines.joined(separator: "\n"),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        topPresenter?.present(alert, animated: true)
    }
}
