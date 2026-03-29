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
                    Text(String(localized: "paywall.title"))
                        .font(.title.bold())
                        .multilineTextAlignment(.center)
                    Text(String(localized: "paywall.subtitle"))
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: 12) {
                    Button {
                        Task {
                            do {
                                try await StoreService.shared.purchase(StoreService.monthlyID)
                                dismiss()
                            } catch {
                                errorMessage = error.localizedDescription
                            }
                        }
                    } label: {
                        Text(String(localized: "paywall.monthly"))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 12))
                            .foregroundStyle(.white)
                    }

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
                        Text(String(localized: "paywall.lifetime"))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray5), in: RoundedRectangle(cornerRadius: 12))
                            .foregroundStyle(.primary)
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
                    Text(String(localized: "paywall.restore"))
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
            .alert(String(localized: "error.title"), isPresented: .constant(errorMessage != nil)) {
                Button(String(localized: "button.ok")) { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }
}
