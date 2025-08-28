//
//  Views.swift
//  PASE
//
//  Created by Maul Camlopz on 27/08/25.
//


import SwiftUI
import MapKit

// MARK: - CharacterListView
struct CharacterListView: View {
    @StateObject private var vm = CharacterListViewModel()
    @State private var showingError = false

    var body: some View {
        NavigationView {
            List {
                ForEach(vm.characters) { character in
                    NavigationLink(destination: CharacterDetailView(viewModel: CharacterDetailViewModel(character: character))) {
                        CharacterRow(character: character)
                            .padding(.vertical, 6)
                    }
                }
                if vm.isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                } else {
                    Color.clear.onAppear {
                        Task {
                            await vm.load(page: vm.page + 1)
                        }
                    }
                }
            }
            .navigationTitle("Characters")
            .refreshable {
                await vm.refresh()
            }
            .task {
                await vm.load(page: 1)
            }
            .alert("Error", isPresented: Binding(get: { vm.errorMessage != nil }, set: { _ in vm.errorMessage = nil })) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(vm.errorMessage ?? "")
            }
        }
    }
}

// MARK: - CharacterRow
struct CharacterRow: View {
    let character: RMCharacter
    @StateObject private var loader: ImageLoader

    init(character: RMCharacter) {
        self.character = character
        _loader = StateObject(wrappedValue: ImageLoader(urlString: character.image))
    }

    var body: some View {
        HStack(spacing: 12) {
            if let img = loader.image {
                Image(uiImage: img)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 64, height: 64)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 64, height: 64)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        ProgressView().scaleEffect(0.6)
                    )
            }
            VStack(alignment: .leading, spacing: 6) {
                Text(character.name).font(.headline)
                Text("\(character.species) • \(character.status)").font(.subheadline).foregroundColor(.secondary)
            }
        }
        .onAppear { loader.load() }
        .onDisappear { loader.cancel() }
    }
}

// MARK: - Detail View
struct CharacterDetailView: View {
    @StateObject var viewModel: CharacterDetailViewModel
    @StateObject private var loader: ImageLoader

    init(viewModel: CharacterDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _loader = StateObject(wrappedValue: ImageLoader(urlString: viewModel.character.image))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if let img = loader.image {
                    Image(uiImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 300)
                        .overlay(ProgressView())
                        .onAppear { loader.load() }
                }

                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(viewModel.character.name).font(.title2).bold()
                        Text("\(viewModel.character.gender) • \(viewModel.character.species)")
                        Text("Status: \(viewModel.character.status)")
                        Text("Location: \(viewModel.character.location.name)").font(.footnote).foregroundColor(.secondary)
                    }
                    Spacer()
                    Button(action: { viewModel.toggleFavorite() }) {
                        Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                            .font(.title2)
                            .foregroundColor(viewModel.isFavorite ? .red : .primary)
                    }
                }
                .padding(.horizontal)
                
                NavigationLink(destination: LocationMapView(locationName: viewModel.character.location.name)) {
                    Text("Ver en mapa").frame(maxWidth: .infinity).padding().background(RoundedRectangle(cornerRadius: 8).stroke())
                }
                .padding(.horizontal)

                Divider().padding(.horizontal)

                Text("Episodios").font(.headline).padding(.horizontal)
                if viewModel.episodes.isEmpty {
                    Text("Cargando episodios...").padding(.horizontal)
                } else {
                    ForEach(viewModel.episodes) { ep in
                        HStack {
                            Text(ep.episode).bold()
                            VStack(alignment: .leading) {
                                Text(ep.name)
                                Text(ep.air_date).font(.footnote).foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 6)
                    }
                }

            }
            .padding(.vertical)
        }
        .navigationTitle(viewModel.character.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadEpisodes()
        }
    }
}


import MapKit

struct MapAnnotationItem: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let title: String
}


struct LocationMapView: View {
    let locationName: String
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 19.4326, longitude: -99.1332),
        span: MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5)
    )
    @State private var annotationItems: [MapAnnotationItem] = []

    var body: some View {
        Map(coordinateRegion: $region, annotationItems: annotationItems) { item in
            // Puedes usar MapMarker, MapPin o un MapAnnotation personalizado
            MapMarker(coordinate: item.coordinate, tint: .blue)
        }
        .onAppear {
            let coord = LocationSimulator.coords(for: locationName)
            region.center = coord
            region.span = MKCoordinateSpan(latitudeDelta: 2.5, longitudeDelta: 2.5)
            annotationItems = [
                MapAnnotationItem(coordinate: coord, title: locationName)
            ]
        }
        .navigationTitle("Ubicación")
    }
}
