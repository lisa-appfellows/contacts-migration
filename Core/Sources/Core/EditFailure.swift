//
//  EditFailure.swift
//  
//
//  Created by Lisa Fellows on 2026-09-26.
//

import Foundation

public enum EditFailure {
    case save, delete
    public var message: String {
        switch self {
        case .save: return Constants.Edit.saveFailure
        case .delete: return Constants.Edit.deleteFailure
        }
    }
}
