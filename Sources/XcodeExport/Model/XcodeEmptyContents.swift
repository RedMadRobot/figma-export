import Foundation

struct XcodeEmptyContents {

    let fileURL = URL(string: "Contents.json")!

    let data = """
    {
      "info" : {
        "version" : 1,
        "author" : "xcode"
      }
    }
    """.data(using: .utf8)!
}
