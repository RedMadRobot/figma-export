import Foundation

public struct AssetResult<Success, Error> {
    public var result: Result<Success, Swift.Error>
    public var warning: AssetsValidatorWarning?

    public func get() throws -> Success {
        try result.get()
    }

    public static func failure(_ error: Swift.Error) -> AssetResult<Success, Error> {
        AssetResult(result: .failure(error), warning: nil)
    }

    public static func success(_ data: Success) -> AssetResult<Success, Error> {
        AssetResult(result: .success(data), warning: nil)
    }

    public static func success(_ data: Success, warning: AssetsValidatorWarning?) -> AssetResult<Success, Error> {
        AssetResult(result: .success(data), warning: warning)
    }
}
