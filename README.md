# C Flake Template

Minimal, editor-agnostic C study environment with Clang, static analysis,
sanitizers, and formatting.

## Tools Included

- **LSP & Editor Support**: `clangd` (reads `.clangd` /
  `build/compile_commands.json` for completion and live `.clang-tidy`
  diagnostics), `neocmakelsp` (configured in `.neocmake.toml`).
- **Static Analysis**: `clang-tidy` (configured in `.clang-tidy`), `cppcheck`,
  `cmake-lint`.
- **Dynamic Analysis & Sanitizers**: AddressSanitizer (ASan) and
  UndefinedBehaviorSanitizer (UBSan) enabled on Debug builds, plus `lldb`.
- **Formatters**: `clang-format` (configured in `.clang-format`), `cmake-format`,
  `nixfmt`.

## Usage

```sh
# Enter development shell
nix develop

# Build and run (includes ASan & UBSan)
cmake -S . -B build && cmake --build build && ./build/c_app

# Run static analysis
cppcheck --enable=style --inconclusive --error-exitcode=1 src/
clang-tidy src/main.c

# Verify build with GCC (sanity check for autograders/professors)
cmake -B build-gcc -DCMAKE_C_COMPILER=gcc && cmake --build build-gcc

# Run pre-commit formatting & checks
nix flake check
```
