import Foundation

struct XcodeEmptyContents {

    let fileURL = URL(string: "Contents.json")!

    let data = """
    {
      "info" : {
        "author" : "xcode",
        "version" : 1
      }
    }

    """.data(using: .utf8)!
}
