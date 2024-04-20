import Foundation

let currentPath = FileManager.default.currentDirectoryPath
print("Current working directory: \(currentPath)")

func uploadItem(url: URL, item: [String: Any]) -> String? {
    guard let name = item["name"] as? String else { return "Failed to decode name" }
    guard let location = item["location"] as? [String: Any] else { return "Failed to decode location" }
    guard let latitude = location["latitude"] as? Double else { return "Failed to decode latitude" }
    guard let longitude = location["longitude"] as? Double else { return "Failed to decode longitude" }
    
    var request = URLRequest(url: URL(string: "https://demo.traccar.org")!)
    request.httpMethod = "POST"
    request.httpBody = "id=\(name)&lat=\(latitude)&lon=\(longitude)".data(using: .utf8)
    request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    
    let semaphore = DispatchSemaphore(value: 0)
    let task = URLSession.shared.dataTask(with: request) { _, _, _ in semaphore.signal() }
    task.resume()
    semaphore.wait()
    return nil
}

func main() -> String? {
    guard let configPath = Bundle.main.path(forResource: "config", ofType: "plist") else { return "Missing configuration file" }
    guard let dict = NSDictionary(contentsOfFile: configPath) as? [String: AnyObject] else { return "Failed to read configuration file" }
    guard let server = dict["server"] as? String else { return "Missing server URL" }
    guard let url = URL(string: server) else { return "Invalid server URL" }
    
    let homeDirectory = FileManager.default.homeDirectoryForCurrentUser.path
    let dataFile = "\(homeDirectory)/Library/Caches/com.apple.findmy.fmipcore/Items.data"
    guard let data = try? Data(contentsOf: URL(fileURLWithPath: dataFile)) else { return "Failed to read \(dataFile)" }
    guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) else { return "Failed to decode JSON" }
    guard let array = jsonObject as? [[String: Any]] else { return "Incorrect JSON format" }
    
    for item in array {
        if let error = uploadItem(url: url, item: item) {
            print(error)
        }
    }
    return nil
}

if let error = main() {
    print(error)
}
