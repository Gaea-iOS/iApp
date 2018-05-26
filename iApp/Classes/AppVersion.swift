//
//  AppVersion.swift
//  LaunchScreen
//
//  Created by 王小涛 on 2018/5/24.
//

import Foundation

public struct SoftwareVersion: Comparable {
    public static func < (lhs: SoftwareVersion, rhs: SoftwareVersion) -> Bool {
        let count = min(lhs.versionElements.count, rhs.versionElements.count)
        for i in 0..<count {
            if lhs.versionElements[i] == rhs.versionElements[i] {
                continue
            }
            return lhs.versionElements[i] < rhs.versionElements[i]
        }
        return lhs.versionElements.count < rhs.versionElements.count
    }
    
    private let version: String
    private let versionElements: [String]
    public init(version: String) {
        self.version = version
        versionElements = version.components(separatedBy: ".")
    }
}
