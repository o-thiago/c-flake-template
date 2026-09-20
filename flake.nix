{
  description = "C development shell with static analysis and formatting";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default";
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, systems, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import systems;
      imports = [ inputs.git-hooks.flakeModule ];

      perSystem =
        {
          config,
          pkgs,
          ...
        }:
        let
          llvm = pkgs.llvmPackages_latest;
        in
        {
          formatter = pkgs.nixfmt-tree;

          pre-commit.settings.hooks = {
            # Formatters
            cmake-format.enable = true;
            nixfmt.enable = true;
            shfmt.enable = true;
            clang-format = {
              enable = true;
              package = llvm.clang-tools;
            };

            # Linters & Static Analysis
            deadnix.enable = true;
            statix.enable = true;
            shellcheck.enable = true;
            markdownlint.enable = true;
            cmake-lint = rec {
              enable = true;
              package = pkgs.cmake-format;
              entry = "${package}/bin/cmake-lint";
              files = "\\.cmake$|CMakeLists.txt";
            };
            cppcheck = rec {
              enable = true;
              package = pkgs.cppcheck;
              entry = "${package}/bin/cppcheck --enable=style --inconclusive --error-exitcode=1";
              files = "\\.(c|h|cpp|hpp)$";
            };

            # Hygiene
            trim-trailing-whitespace.enable = true;
            end-of-file-fixer.enable = true;
          };

          devShells.default = pkgs.mkShell.override { inherit (llvm) stdenv; } {
            CMAKE_GENERATOR = "Ninja";
            C_STANDARD = "23";

            shellHook =
              #bash
              ''
                ${config.pre-commit.installationScript}
                [ -f build/compile_commands.json ] && ln -sf build/compile_commands.json compile_commands.json
              '';

            packages =
              (with llvm; [
                lldb
              ])
              ++ (with pkgs; [
                # Build & Compilers
                cmake
                ninja
                gcc

                # Language Servers for editors
                nil
                neocmakelsp
                bash-language-server
                marksman
              ])
              ++ config.pre-commit.settings.enabledPackages;
          };
        };
    };
}
