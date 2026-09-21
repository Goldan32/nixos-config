# AGENTS.md

## Repository purpose

This repository contains a NixOS system configuration.

## Repository structure

The top level repository is a NixOs configuration.
- Contains host specific configs
- Packages that need system level access (eg. window managers)
- Hosts are in `hosts`

`home` is a submodule that contains a Home-Manager configuration.
- Contains user level packages, all simple programs should be installed here unless
  - A system level package requires it
  - It is a system level package
- Users are defined in `home/users`

`home/dotfiles` is a classic dotfiles repository, a submodule of the Home-Manager configuration.
- Contains all classic configs
- When not specified, ask if a config shall be created here or inline in a home-manager module

## Nix conventions

- Prefer small reusable modules over adding unrelated settings to host files.
- Keep host-specific configuration in `hosts/<hostname>/`.
- Keep reusable behavior in `modules/`.
- Use existing naming and formatting conventions.
- Prefer standard NixOS/Home Manager options over custom activation scripts.
- Avoid `builtins.getEnv` and other impure evaluation unless already required
  by the repository.
- Do not introduce new flake inputs unless the task requires them.
- Do not update `flake.lock` unless necessary for the requested change.
- Do not manually edit `flake.lock`.

## Safety

Do not run any commands that change anything in the system except for the files
contained in this repo and its submodules.

Only run validation for changes when specifically requested.

## Working style

- Make the smallest change that satisfies the request.
- Preserve unrelated configuration.
- Do not opportunistically refactor unrelated modules.
- Check existing modules for established patterns before introducing a new one.
- If there is a bad pattern used somewhere unrelated to the current task, don't fix it but mention it.
- When several valid NixOS approaches exist, prefer the one already used in
  this repository.
- Explain noteworthy architectural choices in the final response.
