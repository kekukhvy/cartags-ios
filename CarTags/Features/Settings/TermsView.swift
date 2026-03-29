//
//  TermsView.swift
//  CarTags
//

import SwiftUI

struct TermsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    section(loc("terms.section.acceptance.title"), loc("terms.section.acceptance.body"))
                    section(loc("terms.section.description.title"), loc("terms.section.description.body"))
                    section(loc("terms.section.free_tier.title"), loc("terms.section.free_tier.body"))
                    section(loc("terms.section.premium.title"), loc("terms.section.premium.body"))
                    section(loc("terms.section.data.title"), loc("terms.section.data.body"))
                    section(loc("terms.section.accuracy.title"), loc("terms.section.accuracy.body"))
                    section(loc("terms.section.liability.title"), loc("terms.section.liability.body"))
                    section(loc("terms.section.changes.title"), loc("terms.section.changes.body"))
                    section(loc("terms.section.contact.title"), loc("terms.section.contact.body"))

                    Text(loc("terms.last_updated"))
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .padding(.top, 8)
                }
                .padding()
            }
            .navigationTitle(loc("settings.terms"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(loc("button.done")) { dismiss() }
                }
            }
        }
    }

    private func section(_ title: String, _ body: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
            Text(body)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}
