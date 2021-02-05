//
//  IcloudError.swift
//  Continuum
//
//  Created by Omri Horowitz on 2/4/21.
//  Copyright © 2021 trevorAdcock. All rights reserved.
//

import Foundation

enum IcloudError: LocalizedError {
    case couldNotDetermine
    case noAccount
    case restricted
    
    var errorDescription: String? {
        switch self {
        case .couldNotDetermine:
            return "Could not determine if Icloud is available."
        case .noAccount:
            return "No Icloud account attached."
        case .restricted:
            return "ICloud account is restricted."
        }
    }
}
