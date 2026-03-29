//
//  LanguageService.swift
//  CarTags
//

import Foundation
import Observation

@Observable
final class LanguageService {
    static let shared = LanguageService()

    private let key = "app_language"

    var language: String {
        didSet {
            UserDefaults.standard.set(language, forKey: key)
            bundle = Self.makeBundle(for: language)
        }
    }

    var locale: Locale { Locale(identifier: language) }
    private(set) var bundle: Bundle

    private init() {
        let saved = UserDefaults.standard.string(forKey: "app_language")
        let system = Locale.current.language.languageCode?.identifier ?? "en"
        let supported = ["en", "de", "ru", "uk"]
        let resolved = saved ?? (supported.contains(system) ? system : "en")
        language = resolved
        bundle = Self.makeBundle(for: resolved)
    }

    private static func makeBundle(for language: String) -> Bundle {
        guard
            let path = Bundle.main.path(forResource: language, ofType: "lproj"),
            let bundle = Bundle(path: path)
        else { return Bundle.main }
        return bundle
    }
}
