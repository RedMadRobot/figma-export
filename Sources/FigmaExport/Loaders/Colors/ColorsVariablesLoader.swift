import FigmaAPI
import FigmaExportCore

/// Loads color variables from Figma
final class ColorsVariablesLoader {
    private let client: Client
    private let variableParams: Params.Common.VariablesColors?
    private let filter: String?

    init(
        client: Client,
        figmaParams: Params.Figma,
        variableParams: Params.Common.VariablesColors?,
        filter: String?
    ) {
        self.client = client
        self.variableParams = variableParams
        self.filter = filter
    }

    func load() throws -> ColorsLoaderOutput {
        guard
            let tokensFileId = variableParams?.tokensFileId,
            let tokensCollectionName = variableParams?.tokensCollectionName
        else { throw FigmaExportError.custom(errorString: "tokensFileId is nil") }

        let meta = try loadVariables(fileId: tokensFileId)

        guard let tokenCollection = meta.variableCollections.first(where: { $0.value.name == tokensCollectionName })
        else { throw FigmaExportError.custom(errorString: "tokensCollectionName not found" ) }

        let variables: [Variable] = tokenCollection.value.variableIds.compactMap { tokenId in
            guard let variableMeta = meta.variables[tokenId] else { return nil }
            return mapVariableMetaToVariable(variableMeta: variableMeta, modeIds: extractModeIds(from: tokenCollection.value))
        }

        return mapVariablesToColorOutput(variables: variables, meta: meta)
    }

    private func loadVariables(fileId: String) throws -> VariablesEndpoint.Content {
        let endpoint = VariablesEndpoint(fileId: fileId)
        return try client.request(endpoint)
    }

    private func extractModeIds(from collections: Dictionary<String, VariableCollectionValue>.Values.Element) -> ModeIds {
        var modeIds = ModeIds()
        collections.modes.forEach { mode in
            switch mode.name {
            case variableParams?.lightModeName:
                modeIds.lightModeId = mode.modeId
            case variableParams?.darkModeName:
                modeIds.darkModeId = mode.modeId
            case variableParams?.lightHCModeName:
                modeIds.lightHCModeId = mode.modeId
            case variableParams?.darkHCModeName:
                modeIds.darkHCModeId = mode.modeId
            default:
                modeIds.lightModeId = mode.modeId
            }
        }
        return modeIds
    }

    private func mapVariableMetaToVariable(variableMeta: VariableValue, modeIds: ModeIds) -> Variable {
        let values = Values(
            light: variableMeta.valuesByMode[modeIds.lightModeId],
            dark: variableMeta.valuesByMode[modeIds.darkModeId],
            lightHC: variableMeta.valuesByMode[modeIds.lightHCModeId],
            darkHC: variableMeta.valuesByMode[modeIds.darkHCModeId]
        )

        return Variable(name: variableMeta.name, description: variableMeta.description, valuesByMode: values)
    }

    private func mapVariablesToColorOutput(
        variables: [Variable],
        meta: VariablesEndpoint.Content
    ) -> ColorsLoaderOutput {
        var colorOutput = Colors()
        variables.forEach { variable in
            handleColorMode(
                variable: variable,
                mode: variable.valuesByMode.light,
                colorsArray: &colorOutput.lightColors,
                filter: filter,
                meta: meta
            )
            handleColorMode(
                variable: variable,
                mode: variable.valuesByMode.dark,
                colorsArray: &colorOutput.darkColors,
                filter: filter,
                meta: meta
            )
            handleColorMode(
                variable: variable,
                mode: variable.valuesByMode.lightHC,
                colorsArray: &colorOutput.lightHCColors,
                filter: filter,
                meta: meta
            )
            handleColorMode(
                variable: variable,
                mode: variable.valuesByMode.darkHC,
                colorsArray: &colorOutput.darkHCColors,
                filter: filter,
                meta: meta
            )
        }
        return (colorOutput.lightColors, colorOutput.darkColors, colorOutput.lightHCColors, colorOutput.darkHCColors)
    }

    private func handleColorMode(
        variable: Variable,
        mode: ValuesByMode?,
        colorsArray: inout [Color],
        filter: String?,
        meta: VariablesEndpoint.Content)
    {
        if case let .color(color) = mode, doesColorMatchFilter(from: variable) {
            colorsArray.append(createColor(from: variable, color: color))
        } else if case let .variableAlias(variableAlias) = mode,
                  let variableMeta = meta.variables[variableAlias.id],
                  let variableCollectionId = meta.variableCollections[variableMeta.variableCollectionId] {
            let modeId = variableCollectionId.modes.first(where: {
                $0.name == variableParams?.primitivesModeName
            })?.modeId ?? variableCollectionId.defaultModeId
            handleColorMode(
                variable: variable,
                mode: variableMeta.valuesByMode[modeId],
                colorsArray: &colorsArray,
                filter: filter,
                meta: meta
            )
        }
    }

    private func doesColorMatchFilter(from variable: Variable) -> Bool {
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
