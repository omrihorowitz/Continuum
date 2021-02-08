//
//  CommentError.swift
//  Continuum
//
//  Created by Omri Horowitz on 2/4/21.
//  Copyright © 2021 trevorAdcock. All rights reserved.
//

import Foundation

enum CommentError: LocalizedError {
    
    case queryError
    case unableToUnwrap
    case thrownError(Error)
    
    var errorDescription: String? {
        switch self {
        case .queryError:
            return "Error querying comments"
        case .unableToUnwrap:
            return "Unable to unwrap"
        case .thrownError(let error):
            return error.localizedDescription
        }
    }
}
