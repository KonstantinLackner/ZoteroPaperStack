import SwiftUI
import UniformTypeIdentifiers

let columns = [
    GridItem(.flexible()),
    GridItem(.flexible())
]

struct ContentView: View {
    @State private var readingState: [String: PaperStatus] = [:]
    
    @State var papers: [Paper] = [
        Paper(id: "1", title: "A Very Serious Paper", authors: "Smith, J."),
        Paper(id: "2", title: "Another Even More Serious Paper", authors: "Müller, A.; Chen, L."),
        Paper(id: "3", title: "Another Even More Serious Paper", authors: "Müller, A.; Chen, L."),
        Paper(id: "4", title: "Another Even More Serious Paper", authors: "Müller, A.; Chen, L."),
        Paper(id: "5", title: "Another Even More Serious Paper With a very long title just to see how the system will handle the entire clipping thing", authors: "Müller, A.; Chen, L."),
        Paper(id: "6", title: "Another Even More Serious Paper With a very long title just to see how the system will handle the entire clipping thing", authors: "Müller, A.; Chen, L."),
        Paper(id: "7", title: "Another Even More Serious Paper With a very long title just to see how the system will handle the entire clipping thing", authors: "Müller, A.; Chen, L."),
        Paper(id: "8", title: "Another Even More Serious Paper With a very long title just to see how the system will handle the entire clipping thing", authors: "Müller, A.; Chen, L."),
        Paper(id: "9", title: "Another Even More Serious Paper With a very long title just to see how the system will handle the entire clipping thing", authors: "Müller, A.; Chen, L."),
        Paper(id: "10", title: "Another Even More Serious Paper With a very long title just to see how the system will handle the entire clipping thing", authors: "Müller, A.; Chen, L."),
        Paper(id: "11", title: "Another Even More Serious Paper With a very long title just to see how the system will handle the entire clipping thing", authors: "Müller, A.; Chen, L.")
    ]
    @State private var showUnread = false
    @State private var showRead = false
    var geoHeight: CGFloat = 0
    
    
    var currentlyReadingMaxHeight: CGFloat {
        showUnread ? geoHeight * 0.25 : geoHeight * 0.45
    }
    
    var toReadMaxHeight: CGFloat {
        showRead ? geoHeight * 0.25 : geoHeight * 0.45
    }
    
    // Renamed to avoid shadowing the papers array
    func filteredPapers(for status: PaperStatus) -> [Paper] {
        papers.filter { readingState[$0.id] == status }
    }
    
    var body: some View {
        GeometryReader {
            geo in
            let geoHeight = geo.size.height
            
            HStack(spacing: 16) {
                
                // LEFT COLUMN
                VStack(spacing: 16) {
                    stackView(
                        title: "Currently Reading",
                        papers: $papers,
                        readingState: $readingState,
                        status: .currentlyReading
                    )
                    .frame(maxHeight: showUnread ? geoHeight / 2 : geoHeight)
                    
                    DisclosureGroup(
                        isExpanded: $showUnread,
                        content: {
                            stackView(
                                title: "Unread",
                                papers: $papers,
                                readingState: $readingState,
                                status: .unread,
                                showTitle: false
                            )
                            .frame(maxHeight: geoHeight / 3)
                        },
                        label: {
                            Text("Unread (\(filteredPapers(for: .unread).count))")
                                .font(.headline)
                                .foregroundColor(Color(red: 0.4, green: 0.278, blue: 0.365))
                        }
                    )
                }
                
                // RIGHT COLUMN
                VStack(spacing: 16) {
                    stackView(
                        title: "To Read",
                        papers: $papers,
                        readingState: $readingState,
                        status: .toRead
                    )
                    .frame(maxHeight: showRead ? geoHeight / 2 : geoHeight)
                    
                    DisclosureGroup(
                        isExpanded: $showRead,
                        content: {
                            stackView(
                                title: "Read",
                                papers: $papers,
                                readingState: $readingState,
                                status: .read,
                                showTitle: false
                            )
                            .frame(maxHeight: geoHeight / 3)
                        },
                        label: {
                            Text("Read (\(filteredPapers(for: .read).count))")
                                .font(.headline)
                                .foregroundColor(Color(red: 0.4, green: 0.278, blue: 0.365))
                        }
                    )
                }
            }
            .padding()
            .frame(maxHeight: .infinity, alignment: .top)
            .animation(.easeInOut(duration: 0.2), value: showUnread)
            .animation(.easeInOut(duration: 0.2), value: showRead)
            .onAppear {
                readingState = loadReadingState()
                
                for paper in papers where readingState[paper.id] == nil {
                    readingState[paper.id] = .unread
                }
            }
            .onChange(of: readingState) {
                saveReadingState(readingState)
            }
        }
    }
    
    
    func stackView(
        title: String,
        papers: Binding<[Paper]>,
        readingState: Binding<[String: PaperStatus]>,
        status: PaperStatus,
        showTitle: Bool = true
    ) -> some View {
        
        VStack(alignment: .leading) {
            if showTitle {
                Text(title)
                    .font(.headline)
                    .foregroundColor(Color(red: 0.4, green: 0.278, blue: 0.365))
            }
            ScrollView {
                VStack(alignment: .leading) {
                    let filtered = papers.wrappedValue.filter { readingState.wrappedValue[$0.id] == status }
                    ForEach(filtered) { paper in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(paper.title)
                                .font(.subheadline)
                                .foregroundColor(Color(red: 0.4, green: 0.278, blue: 0.365))
                            Text(paper.authors)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(4)
                        .background(
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color(red: 0.988, green: 0.973, blue: 0.922))
                        )
                        .onDrag {
                            NSItemProvider(object: paper.id as NSString)
                        }
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 50, maxHeight: .infinity, alignment: .leading)
                .padding(6)
            }
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.secondary.opacity(0.3))
            )
            .onDrop(of: [UTType.text], isTargeted: nil) { providers in
                guard let provider = providers.first else { return false }
                
                provider.loadItem(forTypeIdentifier: UTType.text.identifier, options: nil) { item, _ in
                    if let data = item as? Data,
                       let id = String(data: data, encoding: .utf8) {
                        DispatchQueue.main.async {
                            // update readingState, not Paper
                            readingState.wrappedValue[id] = status
                        }
                    }
                }
                return true
            }
        }
    }
}

#Preview {
    ContentView()
}
