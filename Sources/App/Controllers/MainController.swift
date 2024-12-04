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
