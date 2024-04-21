import Foundation
import os.log

let logger = OSLog(subsystem: "org.traccar.sync", category: "tracking")

func log(_ message: String) {
    os_log("%{public}@", log: logger, type: .info, message)
}

func uploadItem(url: URL, item: [String: Any]) -> String? {
    guard let name = item["name"] as? String else { return "Failed to decode name" }
    guard let location = item["location"] as? [String: Any] else { return "Failed to decode location" }
    guard let latitude = location["latitude"] as? Double else { return "Failed to decode latitude" }
    guard let longitude = location["longitude"] as? Double else { return "Failed to decode longitude" }
    
    log("Sending \(name) location")
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = "id=\(name)&lat=\(latitude)&lon=\(longitude)".data(using: .utf8)
    request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    
    let semaphore = DispatchSemaphore(value: 0)
    var result: String? = nil
    let task = URLSession.shared.dataTask(with: request) { _, _, error in
        result = error?.localizedDescription
        semaphore.signal()
    }
    task.resume()
    semaphore.wait()
    return result
}

func main(server: String) -> String? {
    guard let url = URL(string: server) else { return "Invalid server URL" }
    
    let homeDirectory = FileManager.default.homeDirectoryForCurrentUser.path
    let dataFile = "\(homeDirectory)/Library/Caches/com.apple.findmy.fmipcore/Items.data"
    guard let data = try? Data(contentsOf: URL(fileURLWithPath: dataFile)) else { return "Failed to read \(dataFile)" }
    guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) else { return "Failed to decode JSON" }
    guard let array = jsonObject as? [[String: Any]] else { return "Incorrect JSON format" }

    for item in array {
        if let error = uploadItem(url: url, item: item) {
            log(error)
        }
    }
    return nil
}

if CommandLine.arguments.count > 1 {
    if let error = main(server: CommandLine.arguments[1]) {
        log(error)
    }
} else {
    log("Missing server URL argument")
}
