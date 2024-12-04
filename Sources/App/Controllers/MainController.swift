//
//  MainController.swift
//  forceUpdateAPI-server
//
//  Created by Javier Calatrava on 4/12/24.
//

import Vapor

struct MainController: RouteCollection {
    func boot(routes: any Vapor.RoutesBuilder) throws {
        let minversionRoutesGrouped = routes.grouped("minversion")
        minversionRoutesGrouped.get(use: minVersion)
        
        let sampleRoutesGrouped = routes.grouped("sample")
        sampleRoutesGrouped.post(use: sample)
    }
    
    // MARK: - Sample
    struct SampleRequestData: Content {
        let version: String
        
        mutating func afterDecode() throws {
            guard isValidVersionString(version) else {
                throw Abort(.badRequest, reason: "Wrong version format")
            }
        }
        
        private func isValidVersionString(_ version: String) -> Bool {
            let versionRegex = #"^\d+\.\d+\.\d+$"#
            let predicate = NSPredicate(format: "SELF MATCHES %@", versionRegex)
            return predicate.evaluate(with: version)
        }
    }
    
    @Sendable
    func sample(req: Request) async throws -> SampleResponse {
        let payload = try req.content.decode(SampleRequestData.self)
        let isLatestVersion =  await payload.version == VersionResponse.current().currentVersion
        let isForceUpdate = await VersionResponse.current().forceUpdate
        guard  isLatestVersion ||
               !isForceUpdate else {
            throw Abort(.upgradeRequired) // Force update flag set
        }

        guard await isVersion(payload.version, inRange: (VersionResponse.current().minimumVersion, VersionResponse.current().currentVersion)) else {
            throw Abort(.upgradeRequired) // Version out of valid range
        }
        
        return SampleResponse(data: "Some data...")
    }
    
    func isVersion(_ version: String, inRange range: (min: String, max: String)) -> Bool {
        func parseVersion(_ version: String) -> [Int] {
            return version.split(separator: ".").compactMap { Int($0) }
        }

        func compareVersions(_ version1: [Int], _ version2: [Int]) -> ComparisonResult {
            for (v1, v2) in zip(version1, version2) {
                if v1 < v2 {
                    return .orderedAscending
                } else if v1 > v2 {
                    return .orderedDescending
                }
            }
            return version1.count < version2.count ? .orderedAscending :
                   version1.count > version2.count ? .orderedDescending :
                   .orderedSame
        }

        let versionParts = parseVersion(version)
        let minParts = parseVersion(range.min)
        let maxParts = parseVersion(range.max)

        let isGreaterThanOrEqualToMin = compareVersions(versionParts, minParts) != .orderedAscending
        let isLessThanOrEqualToMax = compareVersions(versionParts, maxParts) != .orderedDescending

        return isGreaterThanOrEqualToMin && isLessThanOrEqualToMax
    }
    
    // MARK: - minversion
   
    @Sendable
    func minVersion(req: Request) async throws -> VersionResponse {
         VersionResponse(
            currentVersion: "2.0.0",
            minimumVersion: "1.5.0",
            forceUpdate: true
        )
    }

}
