//
//  Supabase.swift
//  MachineMemo
//
//  Created by Eric Hurtado on 1/6/25.
//
import Foundation
import Supabase

let supabase = SupabaseClient(
  supabaseURL: URL(string: "SUPABASE_URL")!,
  supabaseKey: "SUPABASE_KEY"
)
