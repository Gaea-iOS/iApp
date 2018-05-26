//
//  iApp.swift
//  LaunchScreen
//
//  Created by 王小涛 on 2018/5/24.
//

import Foundation

struct AppstoreLookupModel: Decodable, Encodable {
    private enum CodingKeys: String, CodingKey {
        case results
    }
    let results: [AppInfo]
}

struct AppInfo: Decodable, Encodable {
    private enum CodingKeys: String, CodingKey {
        case appID = "trackId"
        case currentVersionReleaseDate
        case minimumOSVersion = "minimumOsVersion"
        case releaseNotes
        case version
        case appViewURL = "trackViewUrl"
    }
    
    let appID: Int
    let currentVersionReleaseDate: String
    let minimumOSVersion: String
    let releaseNotes: String?
    let version: String
    let appViewURL: String
}

public class iApp {
    
    public static let shared = iApp()
    
    private let appInfoStoreKey = "iApp_appInfo"
    
    private init() {
        if let data = UserDefaults.standard.object(forKey: appInfoStoreKey) as? Data {
            appInfo = try? JSONDecoder().decode(AppInfo.self, from: data)
        }
        updateAppInfo()
    }
    
    private var appInfo: AppInfo?
    
    public var isLatestVersion: Bool {
        guard let appInfo = appInfo else {
            print("【warning】now, there has no appInfo, treat isLatestVersion as true.")
            return true
        }
        guard let bundlerVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            print("【warning】bundlerVersion are no set, treat isLatestVersion as true. ")
            return true
        }
        return SoftwareVersion(version: bundlerVersion) >= SoftwareVersion(version: appInfo.version)
    }
    
    public func openAppStorePage() {
        guard let appViewURL = appInfo?.appViewURL, let url = URL(string: appViewURL) else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIApplication.shared.openURL(url)
        }
    }
    
    func updateAppInfo() {
        let bundleId = Bundle.main.bundleIdentifier!
        let iTunesServiceURLString = "https://itunes.apple.com/us/lookup?bundleId=\(bundleId)"
        let url = URL(string: iTunesServiceURLString)!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 30)
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error == nil && data != nil {
                resolveData(data!)
            }
            }.resume()
        
        func resolveData(_ data: Data) {
            guard let decodedData = try? JSONDecoder().decode(AppstoreLookupModel.self, from: data),
                let appInfo = decodedData.results.first else { return }
            self.appInfo = appInfo
            saveAppInfo(appInf: appInfo)
        }
        
        func saveAppInfo(appInf: AppInfo) {
            guard let data = try? JSONEncoder().encode(appInfo) else { return }
            UserDefaults.standard.set(data, forKey: appInfoStoreKey)
            UserDefaults.standard.synchronize()
        }
    }
}

