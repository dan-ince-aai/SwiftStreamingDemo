# Realtime Transcription Swift Demo

This Swift script uses AssemblyAI's realtime speech-to-text API to perform real-time audio transcription.

## Prerequisites

- macOS 10.15 or later
- Swift 5.5 or later
- An AssemblyAI API key

## Setup

1. Clone the repository
2. Run `swift package resolve` to fetch dependencies
3. Replace "your_assemblyai_api_key_here" in main.swift (Line 134) with your actual AssemblyAI API key

## Running the Script

1. Open Terminal and navigate to the project directory
2. Run the following command:
   ```
   swift run
   ```

The script will start capturing audio from your default microphone and send it to AssemblyAI for real-time transcription. The transcribed text will be printed to the console.

## Stopping the Script

To stop the script, press `Ctrl+C` in the Terminal.

## Troubleshooting

If you encounter any issues, ensure that:
- Your AssemblyAI API key is correctly set in the `.env` file
- Your microphone is working and accessible
- You have an active internet connection

For more details on the implementation, refer to the `main.swift` file in the `Sources/RealtimeTranscriptionScript/` directory.