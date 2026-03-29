//
//  PaywallView.swift
//  CarTags
//

import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                VStack(spacing: 8) {
                    Text(loc("paywall.title"))
                        .font(.title.bold())
                        .multilineTextAlignment(.center)
                    Text(loc("paywall.subtitle"))
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: 12) {
                    Button {
                        Task {
                            do {
                                try await StoreService.shared.purchase(StoreService.lifetimeID)
                                dismiss()
                            } catch {
                                errorMessage = error.localizedDescription
                            }
                        }
                    } label: {
                        Text(loc("paywall.lifetime"))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 12))
                            .foregroundStyle(.white)
                    }
                }
                .padding(.horizontal)

                Spacer()

                Button {
                    Task {
                        do {
                            try await StoreService.shared.restorePurchases()
                            dismiss()
                        } catch {
                            errorMessage = error.localizedDescription
                        }
                    }
                } label: {
                    Text(loc("paywall.restore"))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
            .alert(loc("error.title"), isPresented: .constant(errorMessage != nil)) {
                Button(loc("button.ok")) { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }
}
