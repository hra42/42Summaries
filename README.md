# 42Summaries

42Summaries is a macOS application that transcribes audio and video files, then generates concise summaries using various LLM providers including Ollama, OpenAI, and Anthropic.

## Testflight
[![Join Beta](https://img.shields.io/badge/Join-TestFlight_Beta-orange.svg)](https://testflight.apple.com/join/yP2NuC4V)

## AppStore
[![Download on the App Store](https://img.shields.io/badge/Download%20on%20the-App%20Store-blue?style=flat-square&logo=apple&logoColor=white)](https://apps.apple.com/de/app/42summaries/id6736508972?l=en-GB&mt=12)

## Features

### Core Features
- Audio and video file transcription using WhisperKit
- Multiple LLM providers for summarization:
  - Ollama (local)
  - OpenAI
  - Anthropic Claude
- Power mode settings for transcription (fast vs. energy efficient)
- Videos will be converted to audio files for transcription
- Export capabilities:
  - PDF export
  - TXT export
  - Microsoft Teams integration
  - Direct export to ChatGPT, Claude, and Perplexity

### UI Features
- Modern SwiftUI interface with sidebar navigation
- Dark mode support
- Progress tracking for transcription
- Real-time notifications
- Customizable prompt library
- Format controls for summaries
- Error handling and user feedback

## Project Structure

### Core Components
- Services
  - TranscriptionService: Handles audio/video transcription using WhisperKit
  - SummaryService: Manages LLM integrations (Ollama, OpenAI, Anthropic)
  - ExportManager: Handles various export formats and destinations
  - TeamsAuthManager: Manages Microsoft Teams integration
  - NotificationManager: Handles system notifications

### Views
- Main Views
  - WelcomeView: Initial user onboarding
  - FileSelectionView: Audio/video file selection
  - TranscriptionView: Transcription process and results
  - SummaryView: Summary generation and editing
  - SettingsView: App configuration and preferences
- Supporting Views
  - LaunchScreenView: App initialization
  - AboutView: App information
  - ExportOptionsView: Export functionality
  - Error/NotificationView: User feedback
  - TeamsSelectionView: Teams integration interface

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
- WhisperKit for transcriptions
- OllamaKit for local LLM integration
- LLMChatOpenAI for OpenAI integration
- LLMChatAnthropic for Claude integration
- MSAL for Microsoft Teams authentication

## Configuration

### LLM Provider Setup
- Ollama: Requires local Ollama installation
- OpenAI: Requires API key in settings
- Anthropic: Requires API key in settings

### Microsoft Teams Integration
- Requires Azure AD application registration
- Configure Client ID and Tenant ID in settings

## Getting Started

1. Launch the application
2. Follow the getting started guide at https://42summaries.com/#get-started
3. Configure your preferred LLM provider in Settings
4. Select an audio/video file to begin transcription
5. Generate and customize summaries as needed

## Additional Notes

- The app uses WhisperKit for offline transcription
- Supports multiple export formats and destinations
- Includes a customizable prompt library for different summary styles
- Features both fast and energy-efficient transcription modes
