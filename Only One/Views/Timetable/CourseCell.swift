import SwiftUI

struct CourseCell: View {
    let course: Course?
    let onTap: (Course?) -> Void
    
    var body: some View {
        Button(action: {
            onTap(course)
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(course?.color.color ?? Color.clear)
                    .opacity(course != nil ? 0.8 : 0.0)
                
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                
                if let course = course {
                    VStack(spacing: 2) {
                        Text(course.title)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .lineLimit(2)
                        
                        if !course.room.isEmpty {
                            Text(course.room)
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.8))
                                .lineLimit(1)
                        }
                    }
                    .padding(4)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    CourseCell(course: nil, onTap: { _ in })
        .frame(width: 100, height: 80)
}
