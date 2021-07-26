import Foundation

struct XcodeFolderNamespaceContents {

    let fileURL = URL(string: "Contents.json")!

    let data = """
    {
      "info" : {
        "author" : "xcode",
        "version" : 1
      },
      "properties" : {
        "provides-namespace" : true
      }
    }

    """.data(using: .utf8)!
}
