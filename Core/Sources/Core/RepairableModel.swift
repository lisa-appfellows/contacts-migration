//
//  RepairableModel.swift
//  
//
//  Created by Lisa Fellows on 2026-09-25.
//

import Foundation
import SwiftData

public protocol RepairableModel: PersistentModel {
    var repairVersion: Int { get set }
}
