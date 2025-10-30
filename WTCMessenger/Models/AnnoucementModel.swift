import Foundation

struct Announcement: Identifiable {
	let id = UUID()
	let title: String
	let message: String
	let segment: String
	let date: Date
}
