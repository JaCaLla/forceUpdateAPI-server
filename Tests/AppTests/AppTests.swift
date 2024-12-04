@testable import App
import XCTVapor
import Testing

@Suite("App Tests", .serialized)
struct AppTests {
    private func withApp(_ test: (Application) async throws -> ()) async throws {
        let app = try await Application.make(.testing)
        do {
            try await configure(app)
            try await test(app)
        }
        catch {
            try await app.asyncShutdown()
            throw error
        }
        try await app.asyncShutdown()
    }
    
    @Test("Test below minium version, no forced")
    func testBelowMinimumVersion() async throws {
        try await withApp { app in
            try await app.test(.POST, "sample", beforeRequest: { req in
                let sampleRequestData = MainController.SampleRequestData(version: "1.4.9")
                try req.content.encode(sampleRequestData)
            }, afterResponse: { res async throws in
                #expect(res.status == .upgradeRequired)
            })
        }
    }
    
    @Test("Test below current (and latest) version, no forced", arguments: ["1.5.0", "1.9.9", "2.0.0"])
    func testBelowCurrentVersion(feVersion: String) async throws {
        try await withApp { app in
            try await app.test(.POST, "sample", beforeRequest: { req in
                let sampleRequestData = MainController.SampleRequestData(version: feVersion)
                try req.content.encode(sampleRequestData)
            }, afterResponse: { res async throws in
                #expect(res.status == .ok)
            })
        }
    }
    
    @Test("Test below minium version, no forced")
    func testAboveMinimumVersion() async throws {
        try await withApp { app in
            try await app.test(.POST, "sample", beforeRequest: { req in
                let sampleRequestData = MainController.SampleRequestData(version: "2.0.1")
                try req.content.encode(sampleRequestData)
            }, afterResponse: { res async throws in
                #expect(res.status == .upgradeRequired)
            })
        }
    }

    @Test("Test below version, forced", arguments: ["1.4.9", "1.5.0", "1.9.9", "2.0.1"])
    func testVersionForced(feVersion: String) async throws {
        try await withApp { app in
            
            await MainActor.run {
                let testVersion = VersionResponse(currentVersion: "2.0.0", minimumVersion: "1.5.0", forceUpdate: true)
                VersionResponse.setTestVersion(testVersion)
            }
            
            try await app.test(.POST, "sample", beforeRequest: { req in
                let newGrocery = MainController.SampleRequestData(version: feVersion)
                try req.content.encode(newGrocery)
            }, afterResponse: { res async throws in
                #expect(res.status == .upgradeRequired)
            })
        }
    }
    
    @Test("Test current version, forced")
    func testCurrentVersionAndForced() async throws {
        try await withApp { app in
            try await app.test(.POST, "sample", beforeRequest: { req in
                let sampleRequestData = MainController.SampleRequestData(version: "2.0.0")
                try req.content.encode(sampleRequestData)
            }, afterResponse: { res async throws in
                #expect(res.status == .ok)
            })
        }
    }
    
    @Test("Test wrong version format")
    func testWrongVersionFormat() async throws {
        try await withApp { app in
            try await app.test(.POST, "sample", beforeRequest: { req in
                let sampleRequestData = MainController.SampleRequestData(version: "2.0")
                try req.content.encode(sampleRequestData)
            }, afterResponse: { res async throws in
                #expect(res.status == .badRequest)
            })
        }
    }

}
