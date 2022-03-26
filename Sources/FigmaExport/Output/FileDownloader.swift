import Foundation
import FigmaExportCore
import Logging
#if os(Linux)
import FoundationNetworking
#endif

final class FileDownloader {

    private let logger = Logger(label: "com.redmadrobot.figma-export.file-downloader")
    private let session: URLSession
    
    init(session: URLSession = URLSession(configuration: .ephemeral, delegate: nil, delegateQueue: nil)) {
        self.session = session
    }

    func fetch(files: [FileContents]) throws -> [FileContents] {
        let group = DispatchGroup()
        var errors: [Error] = []

        var newFiles = [FileContents]()

        let remoteFileCount = files.filter { $0.sourceURL != nil }.count
        var downloaded = 0

        let semaphore = DispatchSemaphore(value: session.configuration.httpMaximumConnectionsPerHost - 1)

        files.forEach { file in
            guard let remoteURL = file.sourceURL else {
                newFiles.append(file)
                return
            }

            let task = session.downloadTask(with: remoteURL) { localURL, _, error in
                defer {
                    semaphore.signal()
                    group.leave()
                }

                guard let fileURL = localURL, error == nil else {
                    errors.append(error!)
                    return
                }
                let newFile = FileContents(
                    destination: file.destination,
                    dataFile: fileURL,
                    scale: file.scale,
                    dark: file.dark,
                    isRTL: file.isRTL
                )
                newFiles.append(newFile)
                downloaded += 1
                self.logger.info("Downloaded \(downloaded)/\(remoteFileCount)")
            }

            group.enter()
            semaphore.wait()
            task.resume()
        }
        group.wait()

        if !errors.isEmpty {
            throw ErrorGroup(all: errors)
        }

        return newFiles
    }
}
