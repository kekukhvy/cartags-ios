//
//  FlagEmoji.swift
//  CarTags
//

func flagEmoji(for countryCode: String) -> String {
    countryCode.uppercased().unicodeScalars.compactMap {
        Unicode.Scalar(127397 + $0.value)
    }.map(String.init).joined()
}
