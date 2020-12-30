import ArgumentParser
import Foundation
import Logging
import FigmaAPI

extension ParsableCommand {
    
    func checkForUpdate(logger: Logger) {
        let client = GitHubClient()
        let endpoint = LatestReleaseEndpoint()
        guard let latestRelease = try? client.request(endpoint) else {
            return
        }
        let latestVersion = latestRelease.tagName
        
        if FigmaExportCommand.version != latestVersion {
            logger.info("""

            ----------------------------------------------------------------------------
            figma-export \(latestVersion) is available. You are on \(FigmaExportCommand.version).
            You should use the latest version.
            Please update using `brew upgrade figma-export` or `pod update FigmaExport`.
            To see what’s new, open https://github.com/RedMadRobot/figma-export/releases
            ----------------------------------------------------------------------------
            """)
        }
    }
    
}
