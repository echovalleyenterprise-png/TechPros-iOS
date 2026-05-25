import Foundation

/// ⚠️  Fill in your Supabase credentials before building.
/// Find them at: Supabase Dashboard → Settings → API
enum Config {
    // MARK: - Supabase
    static let supabaseURL    = "https://oknfuryykgfesreshrag.supabase.co"
    static let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9rbmZ1cnl5a2dmZXNyZXNocmFnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzk1ODczNTQsImV4cCI6MjA5NTE2MzM1NH0.uoYYlda9mjykaei2f0bggItXt9Fb5T6cK5WN5OgVmCc"

    // MARK: - API
    /// Your deployed Vercel backend
    static let apiBaseURL = "https://tech-pros.vercel.app"
}
