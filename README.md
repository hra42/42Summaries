# 42Summaries

42Summaries is a macOS application that transcribes audio and video files, then generates concise summaries using Ollama.

## Current State

The application has a functional user interface implemented with SwiftUI. Core transcription and summarization features are yet to be implemented.

## Project Structure

- 42Summaries
  - Frameworks
    - Speech.framework
    - AVFoundation.framework
  - Products
  - 42Summaries
    - AppDelegate.swift
    - 42Summaries-Info.plist
    - Models
      - TranscriptionStatus.swift
      - NavigationItem.swift
    - Preview Content
    - Utilities
    - ViewModels
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
      - TranscriptionProgressView.swift
    - Assets.xcassets
    - MainWindowView.swift
    - SummariesApp.swift
  - Services

## Implemented Features

- User Interface:
  - Main window with sidebar navigation
  - Welcome screen
  - File selection view
  - Transcription view (UI only)
  - Summary view (UI only)
  - Settings view
  - About view
  - Launch screen
  - Error and notification handling
- App lifecycle management with AppDelegate

## Planned Features

- Audio file transcription
- Video file conversion and transcription
- Summary generation using Ollama
- Progress tracking for transcription and summarization
- File management for transcriptions and summaries

## Requirements

- macOS 15.0+
- Xcode 16.0+
- Swift 6.0+

## Installation

1. Clone the repository
2. Open the project in Xcode
3. Build and run the application

## Upcoming Development

1. Implement Speech Recognition for audio transcription
2. Develop audio and video file handling
3. Integrate Ollama for summary generation
4. Create a transcription queue system
5. Implement progress tracking and error handling

## Dependencies

- SwiftUI for the user interface
- Speech framework (to be implemented)
- AVFoundation framework (to be implemented)
- Ollama with LLama3.2 (to be implemented)
