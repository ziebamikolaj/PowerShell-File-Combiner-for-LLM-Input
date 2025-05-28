# PowerShell File Combiner for LLM Input

**PowerShell File Combiner** is a PowerShell script that aggregates text-based project files into a single text file, ideal for feeding into large-context-window LLMs like Gemini 2.5 Pro or GPT-4. It generates a directory tree and concatenates file contents while excluding binary files and specified directories, making it perfect for developers preparing codebases for AI analysis.

## Features

- **Directory Tree Generation**: Creates a visual representation of your project’s folder structure.
- **File Content Aggregation**: Combines text-based files into a single output file (`CombinedFile.txt` by default).
- **Binary File Exclusion**: Skips binary files (e.g., `.exe`, `.png`, `.pdf`) based on extensions or null-byte detection.
- **Customizable Exclusions**: Exclude specific directories (e.g., `node_modules`, `bin`) and files.
- **Depth Control**: Limit subdirectory recursion with a configurable `MaxDepth` setting.
- **Error Handling**: Gracefully handles file access issues and logs errors to the output file.
- **UTF-8 Encoding**: Ensures compatibility with diverse character sets.

## Use Cases

- Prepare a codebase for AI-driven code analysis or documentation generation.
- Create a single text file for LLM input to summarize or refactor projects.
- Generate a project overview with directory structure and file contents.

## Installation

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/ziebamikolaj/PowerShell-FileCombiner.git
   ```
2. Ensure you have PowerShell 5.1 or later installed (available on Windows or via PowerShell Core on macOS/Linux).
3. Place the script (`Combine-Files.ps1`) in your project directory.

## Usage

Run the script in PowerShell from your project directory:

```powershell
.\Combine-Files.ps1
```

This will:

- Generate a directory tree in `CombinedFile.txt`.
- Append the contents of all text-based files, excluding specified directories and binary files.
- Skip files like the script itself, `CombinedFile.txt`, and others defined in `$ExcludeFiles`.

### Configuration

Edit the script’s `#region Configuration` section to customize:

- **`$OutputPath`**: Set the output file name (default: `CombinedFile.txt`).
- **`$SkipBinaryFiles`**: Set to `$true` to skip binary files (default: `$true`).
- **`$BinaryFileExtensions`**: List of file extensions to treat as binary (e.g., `.exe`, `.png`).
- **`$ExcludeDirectories`**: Directories to skip (e.g., `node_modules`, `bin`).
- **`$ExcludeFiles`**: Files to exclude (e.g., `package-log.json`, the script itself).
- **`$MaxDepth`**: Limit subdirectory depth (`-1` for unlimited).

Example configuration:

```powershell
$OutputPath = "ProjectSummary.txt"
$ExcludeDirectories = @("node_modules", "dist", "build")
$MaxDepth = 3
```

## Example Output

For a project with structure:

```
project/
├── src/
│   ├── main.py
│   └── utils.py
├── README.md
└── bin/
    └── script.sh
```

Running the script produces `CombinedFile.txt` like:

```
Directory Structure:
--------------------
|-- src
    |-- main.py
    |-- utils.py
|-- README.md
--------------------
File Contents:
--------------------
File: C:\project\README.md
--------------------
# Project
This is a sample project...
--------------------
File: C:\project\src\main.py
--------------------
def main():
    print("Hello, world!")
...
--------------------
File: C:\project\src\utils.py
--------------------
def helper():
    return True
...
```

## Requirements

- PowerShell 5.1 or later (Windows) or PowerShell Core (cross-platform).
- Write permissions in the output directory.

## Contributing

Contributions are welcome! Please:

1. Fork the repository.
2. Create a feature branch (`git checkout -b feature/YourFeature`).
3. Commit your changes (`git commit -m "Add YourFeature"`).
4. Push to the branch (`git push origin feature/YourFeature`).
5. Open a pull request.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Keywords

PowerShell, file combiner, LLM input, code aggregation, project summarizer, text file generator, directory tree, AI code analysis, codebase preparation, text-based file processing
