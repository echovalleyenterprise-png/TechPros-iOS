import SwiftUI
import Supabase

@main
struct TechProsApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .preferredColorScheme(.dark)
                .onAppear {
                    // Expose AppState to APIClient without creating a circular dependency
                    AppState.current = appState
                }
        }
    }
}

// MARK: - Supabase singleton
/// One shared SupabaseClient for the entire app.
let supabase = SupabaseClient(
    supabaseURL: URL(string: Config.supabaseURL)!,
    supabaseKey: Config.supabaseAnonKey
)
