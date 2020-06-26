import UIKit

extension HomeViewController {
    func getHostFromPList () -> String? {
        var resourceFileDictionary: NSDictionary?
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
            resourceFileDictionary = NSDictionary(contentsOfFile: path)
        }
        if let resourceFileDictionaryContent = resourceFileDictionary {
            let serverURL = resourceFileDictionaryContent.object(forKey: "serverURL") as! String
            return serverURL
        }
        let alert = UIAlertController(title: "Unable to connect to server", message: "Please try again later", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
        
        return nil
    }
    func getPortFromPList () -> Int? {
        var resourceFileDictionary: NSDictionary?
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
            resourceFileDictionary = NSDictionary(contentsOfFile: path)
        }
        if let resourceFileDictionaryContent = resourceFileDictionary {
            let serverPORT = resourceFileDictionaryContent.object(forKey: "serverPORT") as! Int
            return serverPORT
        }
        return nil
    }
    func setURLToDefaults (_ host:String, _ port:Int) {
        var components = URLComponents()
        components.scheme = "http"
        components.host = host
        components.port = port
        defaults.set(host, forKey: "host")
        defaults.set(port, forKey: "port")
        defaults.set(components.string! as String, forKey: "serverURLString")
    }
}
