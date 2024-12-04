//
//  File.swift
//  forceUpdateAPI-server
//
//  Created by Javier Calatrava on 4/12/24.
//

import Foundation
import Vapor

struct VersionResponse: Content {
    let currentVersion: String
    let minimumVersion: String
    let forceUpdate: Bool

    #if DEBUG
    @MainActor
    private static var testVersion: VersionResponse?
    @MainActor
    static func setTestVersion(_ version: VersionResponse) { testVersion = version }
    #endif

    static func current() async -> VersionResponse {
        let versionResponse = VersionResponse(currentVersion: "2.0.0", minimumVersion: "1.5.0", forceUpdate: false)
        
        #if RELEASE
            return versionResponse
        #else
        //Task { @MainActor in
        return await MainActor.run {
            if isRunningTests(), let testVersion, CommandLine.arguments.contains("-DUNIT_TESTS") {
                return testVersion
            } else {
                return versionResponse
            }
        }
        #endif
    }
    
    static func isRunningTests() -> Bool {
        return ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }
}
