import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var appController: AppController
    @State private var selectedEntry: HistoryEntry?
    @State private var searchText = ""

    private var store: HistoryStore { appController.historyStore }

    private var filtered: [HistoryEntry] {
        guard !searchText.isEmpty else { return store.entries }
        return store.entries.filter {
            $0.displayName.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { appController.navigate(to: .idle) }) {
                    Label("Back", systemImage: "chevron.left")
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)

                Spacer()

                Text("History")
                    .font(.headline)

                Spacer()

                Button(action: { store.reload() }) {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
                .help("Refresh")
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 14)

            Divider()

            if store.entries.isEmpty {
                emptyState
            } else {
                // Search
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search sessions", text: $searchText)
                        .textFieldStyle(.plain)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.primary.opacity(0.04))

                Divider()

                // List
                ScrollView {
                    LazyVStack(spacing: 0) {
                        if filtered.isEmpty {
                            Text("No results for \"\(searchText)\"")
                                .foregroundColor(.secondary)
                                .padding(24)
                        } else {
                            ForEach(filtered) { entry in
                                HistoryRowView(entry: entry) {
                                    selectedEntry = entry
                                }
                                Divider()
                            }
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(item: $selectedEntry) { entry in
            HistoryDetailView(entry: entry)
                .environmentObject(appController)
                .frame(minWidth: 560, minHeight: 460)
        }
        .onAppear { store.reload() }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "clock.badge.xmark")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            Text("No sessions yet.")
                .font(.headline)
            Text("Completed sessions appear here.")
                .foregroundColor(.secondary)
            Spacer()
        }
    }
}

struct HistoryRowView: View {
    let entry: HistoryEntry
    let action: () -> Void
    @State private var isHovered = false

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Mode icon
                Image(systemName: entry.session.mode == .stopwatch ? "stopwatch" : "timer")
                    .font(.title3)
                    .foregroundColor(Color.tsAccent)
                    .frame(width: 32)

                // Info
                VStack(alignment: .leading, spacing: 3) {
                    Text(entry.displayName)
                        .font(.callout).bold()
                    HStack(spacing: 8) {
                        Text(dateFormatter.string(from: entry.session.startDate))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("·")
                            .foregroundColor(.secondary).font(.caption)
                        Text(entry.session.activeElapsed.shortString)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(isHovered ? Color.primary.opacity(0.04) : Color.clear)
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }
}
