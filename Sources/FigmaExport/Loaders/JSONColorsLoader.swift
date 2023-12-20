import Foundation
import FigmaExportCore

final class JSONColorsLoader {
        
    typealias Output = (light: [Color], dark: [Color]?, lightHC: [Color]?, darkHC: [Color]?)
    
    static func processColors(in node: Any, groupName: String) throws -> Output {
        guard
            let node = node as? [String: Any],
            let subNode = node[groupName] as? [String: Any],
            let light = subNode["light"]
        else {
            throw FigmaExportError.stylesNotFoundLocally
        }
        
        return (
            light: processSchemeColors(in: light),
            dark: subNode["dark"].map { processSchemeColors(in: $0) },
            lightHC: subNode["lightHC"].map { processSchemeColors(in: $0) },
            darkHC: subNode["darkHC"].map { processSchemeColors(in: $0) }
        )
    }
    
    static func processSchemeColors(in node: Any, path: [String] = []) -> [Color] {
        // Check if the node contains a color value
        if let color = node as? [String: String], let value = color["value"] {
            let name = path.joined(separator: "_")
            if let def = Color(name: name, value: value) {
                return [def]
            } else {
                return []
            }
        }
        
        // Check if the node is a dictionary
        else if let dictionary = node as? [String: Any] {
            return dictionary.map { (key, value) in
                processSchemeColors(in: value, path: path + [key])
            }.flatMap { $0 }
            
        } else {
            return []
        }
    }
}
