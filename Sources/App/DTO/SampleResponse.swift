//
//  File.swift
//  forceUpdateAPI-server
//
//  Created by Javier Calatrava on 4/12/24.
//

import Foundation
import Vapor

struct SampleResponse: Content {
    let data: String
    let currentVersion: String
    let minimumVersion: String
    let forceUpdate: Bool
}
