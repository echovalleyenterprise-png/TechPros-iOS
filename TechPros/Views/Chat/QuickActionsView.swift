import SwiftUI

struct QuickActionsView: View {
    let actions: [(title: String, prompt: String)]
    let onSelect: (String) -> Void

    let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(actions, id: \.title) { action in
                Button {
                    onSelect(action.prompt)
                } label: {
                    Text(action.title)
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .padding(.horizontal, 10)
                        .background(Color.white.opacity(0.07))
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.12), lineWidth: 1))
                }
            }
        }
    }
}
