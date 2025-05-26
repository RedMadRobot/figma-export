import ArgumentParser
import Foundation
import Logging
import FigmaAPI
    
extension ParsableCommand {
    
    func shouldUpdateFigmaVersion(
        for assetKey: VersionManager.AssetKey,
        options: FigmaExportOptions,
        timeout: TimeInterval? = nil,
        logger: Logger,
        versionManager: VersionManager
    ) -> Date? {
        let fileId = options.params.figma.lightFileId
        let client = FigmaClient(accessToken: options.accessToken, timeout: timeout)
        let endpoint = VersionEndpoint(fileId: fileId)
        guard
            let fileVersions = try? client.request(endpoint),
            let lastVersion = fileVersions.first
        else {
            return nil
        }
        
        let lastVersionDate = lastVersion.createdAt ?? Date()
        let localVersionDate = versionManager.getVersionDate(for: assetKey)
        if let localVersionDate, lastVersionDate > localVersionDate {
            versionManager.setVersionDate(lastVersionDate, for: assetKey)
            logger.info("""

            ----------------------------------------------------------------------------------
            New version available for file: \(fileId)... downloading updates now...
            ----------------------------------------------------------------------------------
            """)
            return nil
        }
        
        logger.info("""

        ----------------------------------------------------------------------------
        You are on the latest file version, nothing to download.
        ----------------------------------------------------------------------------
        """)
        return lastVersionDate
    }
}
