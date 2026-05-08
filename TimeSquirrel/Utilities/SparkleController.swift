import Foundation
import Sparkle

final class SparkleController {
    static let shared = SparkleController()

    private var updaterController: SPUStandardUpdaterController?

    private init() {}

    func configure(updateBehavior: UpdateBehavior) {
        guard isSparkleConfigured else { return }

        switch updateBehavior {
        case .manual:
            updaterController = SPUStandardUpdaterController(
                startingUpdater: false,
                updaterDelegate: nil,
                userDriverDelegate: nil
            )
        case .automatic:
            updaterController = SPUStandardUpdaterController(
                startingUpdater: true,
                updaterDelegate: nil,
                userDriverDelegate: nil
            )
            updaterController?.updater.updateCheckInterval = 86400
        }
    }

    private var isSparkleConfigured: Bool {
        guard
            let key = Bundle.main.object(forInfoDictionaryKey: "SUPublicEDKey") as? String,
            let url = Bundle.main.object(forInfoDictionaryKey: "SUFeedURL") as? String,
            !key.hasPrefix("PLACEHOLDER"),
            !url.isEmpty
        else { return false }
        return true
    }

    func checkForUpdates() {
        updaterController?.checkForUpdates(nil)
    }

    var canCheckForUpdates: Bool {
        updaterController?.updater.canCheckForUpdates ?? false
    }
}
