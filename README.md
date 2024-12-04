# tts-repeating.rb

## Overview

`tts-repeating.rb` is a Ruby script designed for English repetition practice. It takes a text file, splits it into individual sentences, and generates corresponding audio files in MP3 format using Text-to-Speech (TTS). This allows users to practice their pronunciation and listening skills sentence by sentence.

## Prerequisites

**OpenAI API Key**: Set your OpenAI API key in a `.env` file in the following format:
```
OPENAI_API_KEY=your_openai_api_key
```

## Installation

1. Clone or download the script.
2. Install required Ruby gems using `bundle` command:
   ```bash
   $ bundle
   ```
3. Create a `.env` file in the project directory and add your OpenAI API key.

## Usage

Run the script with the following command:

```bash
ruby tts-repeating.rb [options]
```

### Options

- **`-f FILE`**: Specify the input text file.
  - Example: `-f input.txt`
- **`-p PREFIX`**: Set a prefix for output audio files.
  - Default: Current timestamp (e.g., `202412051430`).
  - Example: `-p my_audio`
- **`-v VOICE`**: Choose a voice for the TTS output. Available voices:
  - `alloy`, `echo`, `fable`, `onyx`, `nova`, `shimmer`
  - Example: `-v shimmer`
- **`-h`**: Display help information.

## Example

To process a file named `sample.txt` with the `shimmer` voice and a custom prefix:

```bash
ruby tts-repeating.rb -f sample.txt -p practice -v shimmer
```

Output:
- MP3 files named `practice-01.mp3`, `practice-02.mp3`, etc.

Output files will be generated in the script's directory.

## License

This script is open-source and can be used or modified under the terms of the MIT License.
