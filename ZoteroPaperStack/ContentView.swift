//
// ContentView.swift
// ZoteroPaperStack
//
// Created by Konstantin Lackner on 30/01/2026.
//

import SwiftUI
import UniformTypeIdentifiers

let columns = [
    GridItem(.flexible()),
    GridItem(.flexible())
]

struct ContentView: View {
    @State var papers: [Paper] = [
        Paper(id: "1", title: "A Very Serious Paper", authors: "Smith, J.", status: .unread),
        Paper(id: "2", title: "Another Even More Serious Paper", authors: "Müller, A.; Chen, L.", status: .unread),
        Paper(id: "3", title: "Another Even More Serious Paper With a very long title just to see how the system will handle the entire clipping thing", authors: "Müller, A.; Chen, L.", status: .unread)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 20) {
            // Pass a binding ($papers)
            stackView(title: "Currently Reading", papers: $papers, status: .currentlyReading)
            stackView(title: "To Read", papers: $papers, status: .toRead)
            stackView(title: "Unread", papers: $papers, status: .unread)
            stackView(title: "Read", papers: $papers, status: .read)
        }
        .padding()
        .frame(minWidth: 600, minHeight: 400)
    }
    
    func papers(for status: PaperStatus) -> [Paper] {
        papers.filter { $0.status == status }
    }
}

func stackView(title: String, papers: Binding<[Paper]>, status: PaperStatus) -> some View {
    VStack(alignment: .leading) {
        Text(title)
            .font(.headline)
            .foregroundColor(Color(red: 0.4, green: 0.278, blue: 0.365))
        
        ScrollView {
            VStack(alignment: .leading) {
                // Filtered copy for display; doesn't mutate the copy
                ForEach(papers.wrappedValue.filter { $0.status == status }) { paper in
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
        // Drop handled on ScrollView; mutate via binding
        .onDrop(of: [UTType.text], isTargeted: nil) { providers in
            guard let provider = providers.first else { return false }

            provider.loadItem(forTypeIdentifier: UTType.text.identifier, options: nil) { item, _ in
                if let data = item as? Data,
                   let id = String(data: data, encoding: .utf8) {
                    DispatchQueue.main.async {
                        if let index = papers.wrappedValue.firstIndex(where: { $0.id == id }) {
                            papers.wrappedValue[index].status = status
                        }
                    }
                }
            }
            
            return true
        }
    }
}


#Preview {
    ContentView()
}
