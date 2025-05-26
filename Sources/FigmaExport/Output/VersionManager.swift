import Foundation
import Logging
#if os(Linux)
import FoundationNetworking
#endif

class VersionManager {
    private let versionFileURL: URL
    private let dateFormatter = ISO8601DateFormatter()
    private let logger = Logger(label: "com.redmadrobot.figma-export.version-manager")
    
    enum AssetKey: String, CaseIterable, Codable {
        case images
        case icons
        case typography
        case colors
    }
    
    private var versionDates: [String: String] = [:]
    
    init(versionFilePath: String) {
        self.versionFileURL = URL(fileURLWithPath: versionFilePath)
        loadVersionDates()
    }
    
    private func loadVersionDates() {
        guard FileManager.default.fileExists(atPath: versionFileURL.path) else { return }
        
        do {
            let data = try Data(contentsOf: versionFileURL)
            let rawDict = try JSONDecoder().decode([String: String].self, from: data)
            
            for (key, dateString) in rawDict {
                if let assetKey = AssetKey(rawValue: key) {
                    versionDates[assetKey.rawValue] = dateString
                }
            }
        } catch {
            logger.error("Failed to load version data: \(error)")
        }
    }
    
    private func saveVersionDates() {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: versionDates, options: .prettyPrinted)
            try jsonData.write(to: versionFileURL, options: .atomic)
        } catch {
            logger.error("Failed to save version data: \(error)")
        }
    }
    
    func getVersionDate(for asset: AssetKey) -> Date? {
        guard let dateString = versionDates[asset.rawValue] else { return nil }
        return dateFormatter.date(from: dateString)
    }
    
    func setVersionDate(_ date: Date, for asset: AssetKey) {
        let dateString = dateFormatter.string(from: date)
        versionDates[asset.rawValue] = dateString
        saveVersionDates()
    }
}

