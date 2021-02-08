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
            return "couldNotDetermine"
        case .noAccount:
            return "noAccount"
        case .restricted:
            return "restricted"
        }
    }
}
