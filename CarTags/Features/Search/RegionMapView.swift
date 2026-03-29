//
//  RegionMapView.swift
//  CarTags
//

import SwiftUI
import MapKit

struct RegionMapView: View {
    let region: RegionResult
    @Environment(\.dismiss) private var dismiss

    private var coordinate: CLLocationCoordinate2D? {
        guard let lat = region.lat, let lon = region.lon else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    var body: some View {
        NavigationStack {
            Group {
                if let coordinate {
                    Map(initialPosition: .region(MKCoordinateRegion(
                        center: coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 2.0, longitudeDelta: 2.0)
                    ))) {
                        Marker(region.regionName, coordinate: coordinate)
                    }
                    .ignoresSafeArea(edges: .bottom)
                } else {
                    ContentUnavailableView(
                        loc("map.no_location.title"),
                        systemImage: "map.fill",
                        description: Text(loc("map.no_location.message"))
                    )
                }
            }
            .navigationTitle("\(flagEmoji(for: region.countryCode)) \(region.regionName)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.secondary)
                            .padding(8)
                            .background(Color(.systemGray5), in: Circle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
