import Foundation
import FigmaExportCore

final public class AndroidComposeIconExporter {

    private let output: AndroidOutput

    public init(output: AndroidOutput) {
        self.output = output
    }

    public func exportIcons(iconNames: [String]) throws -> [FileContents] {
        var files: [FileContents] = []
        
        if let composeOutputDirectory = output.composeOutputDirectory, let packageName = output.packageName {
            files.append(makeComposeIconsFile(iconNames: iconNames, outputDirectory: composeOutputDirectory, package: packageName))
        }
        
        return files
    }
    
    private func makeComposeIconsFile(iconNames: [String], outputDirectory: URL, package: String) -> FileContents {
        let fileURL = URL(string: "Icons.kt")!
        
        let fileLines: [String] = iconNames.map {
            let functionName = $0.camelCased()
            return """
            @Composable
            fun Icons.\(functionName)(
                contentDescription: String?,
                modifier: Modifier = Modifier,
                tint: Color = LocalContentColor.current.copy(alpha = LocalContentAlpha.current)
            ) {
                Icon(
                    painter = painterResource(id = R.drawable.\($0)),
                    contentDescription = contentDescription,
                    modifier = modifier,
                    tint = tint
                )
            }
            """
        }
        let contents = """
        package \(package)
        
        import androidx.compose.material.Icon
        import androidx.compose.material.LocalContentAlpha
        import androidx.compose.material.LocalContentColor
        import androidx.compose.runtime.Composable
        import androidx.compose.ui.Modifier
        import androidx.compose.ui.graphics.Color
        import androidx.compose.ui.res.painterResource
        import \(output.xmlResourcePackage).R

        object Icons
        
        \(fileLines.joined(separator: "\n\n"))
        
        """
        let data = contents.data(using: .utf8)!
        
        let destination = Destination(directory: outputDirectory, file: fileURL)
        return FileContents(destination: destination, data: data)
    }
}
