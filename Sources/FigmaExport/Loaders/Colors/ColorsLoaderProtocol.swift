import FigmaAPI
import FigmaExportCore

typealias ColorsLoaderOutput = (light: [Color], dark: [Color]?, lightHC: [Color]?, darkHC: [Color]?)

protocol ColorsLoaderProtocol {
    func load(filter: String?) throws -> ColorsLoaderOutput
}
