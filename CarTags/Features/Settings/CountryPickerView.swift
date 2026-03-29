//
//  CountryPickerView.swift
//  CarTags
//

import SwiftUI

struct CountryPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = CountryPickerViewModel()
    @State private var showLimitAlert = false

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.countries) { country in
                        CountryPickerRow(
                            country: country,
                            showLimitAlert: $showLimitAlert
                        )
                        Divider().padding(.leading, 56)
                    }
                }
            }
            .navigationTitle(String(localized: "countries.picker.title"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(String(localized: "button.done")) { dismiss() }
                }
            }
            .task { viewModel.loadCountries() }
            .alert(String(localized: "error.title"), isPresented: $showLimitAlert) {
                Button(String(localized: "button.ok")) {}
            } message: {
                Text(String(localized: "countries.picker.limit"))
            }
            .alert(String(localized: "error.title"), isPresented: .constant(viewModel.errorMessage != nil)) {
                Button(String(localized: "button.ok")) { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
}

private struct CountryPickerRow: View {
    let country: CountryItem
    @Binding var showLimitAlert: Bool

    var body: some View {
        let isSelected = StoreService.shared.selectedCountries.contains(country.code)
        Button {
            if isSelected {
                StoreService.shared.removeCountry(country.code)
            } else if StoreService.shared.selectedCountries.count >= StoreService.maxFreeCountries {
                showLimitAlert = true
            } else {
                StoreService.shared.addCountry(country.code)
            }
        } label: {
            HStack {
                Text(flagEmoji(for: country.code))
                    .font(.title2)
                Text(country.name)
                    .foregroundStyle(.primary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(Color.accentColor)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }
}
