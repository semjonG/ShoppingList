import SwiftUI

struct ShoppingItemRow: View {
    let item: Item
    let onToggleBought: () async -> Void
    let onEdit: () -> Void
    let onDelete: () async -> Void
    
    var body: some View {
        HStack {
            // bought/unbought button
            Button(action: {
                Task {
                    await onToggleBought()
                }
            }) {
                Image(systemName: item.isBought ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(item.isBought ? .green : .gray)
                    .font(.title2)
            }
            .buttonStyle(PlainButtonStyle())
            
            // item details
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(item.name)
                        .font(.headline)
                        .strikethrough(item.isBought)
                        .foregroundColor(item.isBought ? .secondary : .primary)
                    
                    Spacer()
                    
                    Text("Qty: \(item.quantity)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.secondary.opacity(0.2))
                        .cornerRadius(4)
                }
                
                if let note = item.note, !note.isEmpty {
                    Text(note)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .strikethrough(item.isBought)
                }
                
                Text("Created: \(item.createdAt, style: .date)")
                    .font(.caption2)
                    .foregroundColor(.secondary.opacity(0.6))
            }
            
            // action buttons
            HStack(spacing: 16) {
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .foregroundColor(.blue)
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {
                    Task {
                        await onDelete()
                    }
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.vertical, 4)
        .opacity(item.isBought ? 0.7 : 1.0)
    }
} 
