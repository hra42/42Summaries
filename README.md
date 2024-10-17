# 42Summaries

42Summaries is a macOS application that transcribes audio and video files, then generates concise summaries using Ollama.

## Testflight
[![Join Beta](https://img.shields.io/badge/Join-TestFlight_Beta-orange.svg)](https://testflight.apple.com/join/yP2NuC4V)

## AppStore
[![Download on the App Store](https://img.shields.io/badge/Download%20on%20the-App%20Store-blue?style=flat-square&logo=apple&logoColor=white)](https://apps.apple.com/de/app/42summaries/id6736508972?l=en-GB&mt=12)

## Project Structure

- 42Summaries
    - 42Summaries
        - AppDelegate.swift
        - AppState.swift
        - 42Summaries-Info.plist
        - Models
            - TranscriptionStatus.swift
            - NavigationItem.swift
        - Utilities
            - ExportManager.swift
            - NavigationStateManager.swift
            - NotificationManager.swift
        - Views
            - LaunchScreenView.swift
            - AboutView.swift
            - ToastView.swift
            - NotificationView.swift
            - ErrorView.swift
            - ExportOptionsView.swift
            - FileSelectionView.swift
            - TranscriptionView.swift
            - SummaryView.swift
            - SettingsView.swift
            - WelcomeView.swift
            - SidebarView.swift
            - ToastView.swift
            - WelcomeView.swift
        - MainWindowView.swift
        - SummariesApp.swift
        - Services
            - SummaryService.swift
            - TranscriptionManager.swift
            - TranscriptionService.swift

## Implemented Features

- User Interface:
    - Main window with sidebar navigation
    - Welcome screen
    - File selection view
    - Transcription view
    - Summary view
    - Settings view
    - About view
    - Launch screen
    - Error and notification handling
- App lifecycle management with AppDelegate

## Planned Features

- embed transcription model into the bundle
- Add MLX for summary (use llm directly instead of ollama, also includes integrations with OpenAI and Anthropic)
- Prompt Libary

## Requirements

- macOS 15.0+
- Xcode 16.0+
- Swift 6.0+

## Installation

1. Clone the repository
2. Open the project in Xcode
3. Build and run the application

## Dependencies

- SwiftUI for the user interface
- OllamaKit for Interactions with Ollama
- whisperkit for transcriptions
    - swift-argument-parser
    - swift-transformers
