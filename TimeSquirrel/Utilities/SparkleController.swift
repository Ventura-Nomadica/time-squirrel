import Foundation
import Sparkle

final class SparkleController {
    static let shared = SparkleController()

    private var updaterController: SPUStandardUpdaterController?

    private init() {}

    func configure(updateBehavior: UpdateBehavior) {
        switch updateBehavior {
        case .manual:
            // Manual mode: build the updater but do not start automatic checks.
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

    func checkForUpdates() {
        updaterController?.checkForUpdates(nil)
    }

    var canCheckForUpdates: Bool {
        updaterController?.updater.canCheckForUpdates ?? false
    }
}
