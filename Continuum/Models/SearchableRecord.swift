//
//  SearchableRecord.swift
//  Continuum
//
//  Created by Omri Horowitz on 2/3/21.
//  Copyright © 2021 trevorAdcock. All rights reserved.
//

import Foundation

protocol SearchableRecord: AnyObject {
    func matches(searchTerm: String) -> Bool
}
