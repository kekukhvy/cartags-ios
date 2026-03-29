//
//  Extensions.swift
//  CarTags
//

import Foundation
import SwiftUI

/// Localize a key using the user's chosen in-app language bundle.
func loc(_ key: String) -> String {
    NSLocalizedString(key, tableName: "AppStrings", bundle: LanguageService.shared.bundle, comment: "")
}
