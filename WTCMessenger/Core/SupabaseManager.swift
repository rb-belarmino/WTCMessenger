import Supabase
import Foundation

class SupabaseManager {
	static let shared = SupabaseManager()
	let client: SupabaseClient

	private init() {
		client = SupabaseClient(
			supabaseURL: URL(string: "https://zdbgrjruxvusiycfrawe.supabase.co")!,
			supabaseKey: "sb_publishable_oOubZ4ChuHUIhTVVX9v69w_gnFuZGKr"
		)
	}
}
