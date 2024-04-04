import FigmaAPI
import FigmaExportCore

/// Loads variables colors from Figma
final class ColorsVariablesLoader: ColorsLoaderProtocol {
    private let client: Client
    private let variableParams: Params.Common.VariablesColors?

    init(client: Client, figmaParams: Params.Figma, variableParams: Params.Common.VariablesColors?) {
        self.client = client
        self.variableParams = variableParams
    }

    func load(filter: String?) throws -> ColorsLoaderOutput {
        guard
            let tokensFileId = variableParams?.tokensFileId,
            let tokensCollectionName = variableParams?.tokensCollectionName
        else { throw FigmaExportError.custom(errorString: "tokensFileId or tokensLightCollectionName is nil") }

        return try loadProcess(
            colorTokensFileId: tokensFileId,
            tokensCollectionName: tokensCollectionName,
            filter: filter
        )
    }

    private func loadProcess(
        colorTokensFileId: String,
        tokensCollectionName: String,
        filter: String?
    ) throws -> ColorsLoaderOutput {
        // Load variables
        let meta = try loadVariables(fileId: colorTokensFileId)

        guard let tokenCollection = meta.variableCollections.filter({ $0.value.name == tokensCollectionName }).first
        else { throw FigmaExportError.custom(errorString: "tokensCollectionName is nil") }

        let tokensId = tokenCollection.value.variableIds
        let modeIds = extractModeIds(from: tokenCollection.value)
        let primitivesModeName = variableParams?.primitivesModeName

        let variables: [Variable] = tokensId.compactMap { tokenId in
            guard let variableMeta = meta.variables[tokenId]
            else { return nil }

            let values = Values(
                light: variableMeta.valuesByMode[modeIds.lightModeId],
                dark: variableMeta.valuesByMode[modeIds.darkModeId],
                lightHC: variableMeta.valuesByMode[modeIds.lightHCModeId],
                darkHC: variableMeta.valuesByMode[modeIds.darkHCModeId]
            )

            return Variable(
                name: variableMeta.name,
                description: variableMeta.description,
                valuesByMode: values
            )
        }

        var colors = Colors()
        func handleColorMode(variable: Variable, mode: ValuesByMode?, colorsArray: inout [Color]) {
            if case let .color(color) = mode {
               guard doesColorMatchFilter(from: variable, filter: filter) else { return }
               colorsArray.append(createColor(from: variable, color: color))
           } else if case let .variableAlias(variableAlias) = mode {
                guard
                    let variableMeta = meta.variables[variableAlias.id],
                    let variableCollectionId = meta.variableCollections[variableMeta.variableCollectionId]
                else { return }
                let modeId = variableCollectionId.modes
                    .filter { $0.name == primitivesModeName }
                    .first?.modeId ?? variableCollectionId.defaultModeId
               handleColorMode(variable: variable, mode: variableMeta.valuesByMode[modeId], colorsArray: &colorsArray)
            }
        }
        variables.forEach { value in
            handleColorMode(variable: value, mode: value.valuesByMode.light, colorsArray: &colors.lightColors)
            handleColorMode(variable: value, mode: value.valuesByMode.dark, colorsArray: &colors.darkColors)
            handleColorMode(variable: value, mode: value.valuesByMode.lightHC, colorsArray: &colors.lightHCColors)
            handleColorMode(variable: value, mode: value.valuesByMode.darkHC, colorsArray: &colors.darkHCColors)
        }
        return (colors.lightColors, colors.darkColors, colors.lightHCColors, colors.darkHCColors)
    }

    private func loadVariables(fileId: String) throws -> VariablesEndpoint.Content {
        let endpoint = VariablesEndpoint(fileId: fileId)
        return try client.request(endpoint)
    }

    private func extractModeIds(from collections: Dictionary<String, VariableCollectionId>.Values.Element) -> ModeIds {
        var modeIds = ModeIds()
        collections.modes.forEach {
            switch $0.name {
            case variableParams?.lightModeName:
                modeIds.lightModeId = $0.modeId
            case variableParams?.darkModeName:
                modeIds.darkModeId = $0.modeId
            case variableParams?.lightHCModeName:
                modeIds.lightHCModeId = $0.modeId
            case variableParams?.darkHCModeName:
                modeIds.darkHCModeId = $0.modeId
            default:
                modeIds.lightModeId = $0.modeId
            }
        }
        return modeIds
    }

    private func doesColorMatchFilter(from variable: Variable, filter: String?) -> Bool {
        guard let filter = filter else { return true }
        let assetsFilter = AssetsFilter(filter: filter)
        return assetsFilter.match(name: variable.name)
    }

    private func createColor(from variable: Variable, color: PaintColor) -> Color {
        return Color(
            name: variable.name,
            platform: Platform(rawValue: variable.description),
            red: color.r,
            green: color.g,
            blue: color.b,
            alpha: color.a
        )
    }
}

private extension ColorsVariablesLoader {
    struct ModeIds {
        var lightModeId = String()
        var darkModeId = String()
        var lightHCModeId = String()
        var darkHCModeId = String()
    }

    struct Colors {
        var lightColors: [Color] = []
        var darkColors: [Color] = []
        var lightHCColors: [Color] = []
        var darkHCColors: [Color] = []
    }

    struct Values {
        let light: ValuesByMode?
        let dark: ValuesByMode?
        let lightHC: ValuesByMode?
        let darkHC: ValuesByMode?
    }

    struct Variable {
        let name: String
        let description: String
        let valuesByMode: Values
    }
}
