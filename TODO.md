# Configuration audit TODO

Audit date: 2026-09-21

Scope: all 126 tracked files were reviewed recursively: 30 in the NixOS repository, 20 in the Home Manager repository, and 76 in the dotfiles repository. Git internals and generated build outputs were excluded. This audit deliberately preserves the three standalone repositories and their submodule relationship. No configuration was changed and no builds, evaluations, or system-changing validation commands were run.

Severity means:

- **HIGH**: currently broken, non-portable, non-reproducible, or a meaningful security risk.
- **MEDIUM**: structural debt, brittle behavior, or unnecessary duplication with a clear standard option available.
- **LOW**: maintainability, clarity, formatting, or minor robustness work.

## HIGH

- [ ] Fix the standalone `tv` Home Manager output. `home/flake.nix` omits `jotter` from `homeConfigurations.tv.extraSpecialArgs`, but both `home/users/tv.nix` and its imported `home/modules/common.nix` require it. The embedded NixOS configuration happens to inject it, so this specifically breaks the promised standalone interface. Prefer one profile factory that receives a consistent shared argument set and adds profile-only arguments explicitly.

- [ ] Make local flake inputs portable and stop recording machine-specific paths. `flake.lock` pins `home-config` to `/home/goldan/nixos-config/home`, while `home/flake.lock` pins `dotfiles` to `/home/goldan/nixos-config/home/dotfiles`; those paths do not even match this checkout. Define local inputs with relative path values, keep development overrides out of lock-writing commands, and regenerate locks with Nix rather than editing them. Current Nix supports relative path inputs and nested override paths such as `home-config/dotfiles`.

- [ ] Correct the dotfiles input model. Home Manager only consumes the dotfiles source tree, so declare the input with `flake = false`; this preserves the standalone classic-dotfiles repository while avoiding evaluation of its unrelated Nixpkgs input and lock graph. If the dotfiles flake is intentionally retained as a separate public interface, fix its package: `cp -r * $out/` excludes `.config`, `.local`, `.zsh`, `.zshrc`, and every other hidden path, so the advertised `dotfiles` package currently contains almost none of the dotfiles.

- [ ] Repair `rebuild.sh`'s input override and failure handling. `dotfiles` is not a direct root input, so `--override-input dotfiles ...` does not address the nested input; use `--override-input home-config/dotfiles path:"$DOTFILES"` if an override remains necessary. Also add `set -euo pipefail`, validate the exact argument count and target before invoking `sudo`, quote the complete flake reference as `"${PROOT}#${TARGET}"`, provide `--help`, and `exec` the final rebuild. Keep the script at root if it remains the primary entry point; moving only this file into `scripts/` would not materially improve the repository.

- [ ] Re-establish reproducibility for Neovim and Zsh plugins without moving the configs out of the dotfiles repository. `home/dotfiles/.config/nvim/.gitignore` explicitly ignores `lazy-lock.json`, while `init.lua` clones `lazy.nvim` and all plugins at runtime. Commit the Lazy lockfile (or package the plugins from Nix) and make updates explicit. Likewise, `.zsh/scripts/plugin_utils.sh` clones two mutable plugin default branches during interactive shell startup; pin every plugin revision and avoid startup-time network mutation. The existing pinned `zsh-vi-mode` revision is the right direction.

- [ ] Narrow the system security defaults in `modules/common.nix` and the host files. Every host enables OpenSSH and Docker, every user gets `docker` and raw-disk access through `disk`, and every host disables the firewall. `docker` and `disk` are effectively root-equivalent privileges. Make SSH, Docker, privileged groups, and firewall openings opt-in host/role modules; enable the firewall by default; and explicitly configure SSH authentication policy on the hosts that need it.

- [ ] Replace the broad privilege path used by NVIDIA fan control. `modules/nvidia.nix` grants user `goldan` permission to manage *any* systemd unit, not only the intended fan service. `modules/nfancurve.nix` additionally grants root access to the user's X display with `xhost`. Scope authorization to the exact unit/action or redesign the service so it does not require an unrestricted systemd policy/X access. Also move `After` out of `serviceConfig` into the unit-level `after`/`requires` fields; the current placement is not a valid `[Service]` directive.

- [ ] Guard the Obsidian Neovim plugin. `home/dotfiles/.config/nvim/lua/plugins/obsidian.lua` calls `vim.fn.expand(os.getenv("OBSIDIAN_DEFAULT_VAULT"))` while no tracked configuration defines that variable. An unset variable can break plugin-spec evaluation for every profile. Conditionally return/enable the plugin only when a non-empty vault path exists, or set the variable in the specific Home Manager profile that owns the vault.

## MEDIUM

- [ ] Replace internal Home Manager argument injection in root `flake.nix`. `_module.args.*` is repeated for one user and couples the root flake to Home Manager internals. Use the documented `home-manager.extraSpecialArgs`, keep `home-manager.users.goldan = import ...`, and consider `home-manager.useGlobalPkgs = true` plus `useUserPackages = true`. If global packages are enabled, first move the Obsidian/unfree policy to the system `nixpkgs.config`, because Home Manager's own `nixpkgs.*` options are disabled in that mode.

- [ ] Deduplicate the root flake graph. Make the nested `home-config` inputs for Nixpkgs and Home Manager follow the root inputs so the embedded configuration does not evaluate parallel copies. This does not affect `home/flake.nix` when it is used standalone. The current root lock contains duplicate Home Manager and Nixpkgs nodes even when their revisions match.

- [ ] Simplify `mkHost` and shared imports in root `flake.nix`. Its `name` argument is unused, and `modules/common.nix` is imported both by `mkHost` and by every host except that Nix de-duplicates the module. Pick one owner for the common import, remove the unused argument, and add `networking.hostName` to `hosts/vm/configuration.nix` (or deliberately derive host names in `mkHost`). Preserve `media-server` as an explicit exception if that hostname is intentional.

- [ ] Split `modules/common.nix` by responsibility. A minimal base module should not also own Docker, desktop storage services, the interactive user, privileged groups, Home Manager CLI, MTP, development tools, and VPN tooling. Suggested reusable roles are `base`, `desktop`, `containers`, and `user-goldan`; hosts should opt into only what they need. This also removes the current mismatch where the VM and server inherit workstation behavior.

- [ ] Extract the repeated workstation host settings from `hosts/pc/configuration.nix` and `hosts/zenbook/configuration.nix` into a small desktop module: systemd-boot, NetworkManager, MTR, GnuPG agent, PipeWire, and the shared kernel policy. Keep hardware, hostname, Windows boot entry, and host-only imports in each host. The server should share only settings that actually apply to it.

- [ ] Fix the generation limit in `modules/cleanup.nix`. All configured hosts use systemd-boot, but cleanup sets `boot.loader.grub.configurationLimit`, so it has no effect. Use `boot.loader.systemd-boot.configurationLimit` (and choose a deliberate value), or keep bootloader-specific limits in host/bootloader modules. Consider `nix.optimise.automatic = true` separately; it is complementary to GC, not a replacement.

- [ ] Move user-session behavior out of system activation. `modules/sway.nix` starts Sway through `environment.loginShellInit` and tries to reload a user's running compositor from a root activation script. Use a supported display/login manager session plus Home Manager's Sway/systemd integration. Move `modules/kodi.nix`'s package and user unit into the `tv` Home Manager profile unless a concrete system-level requirement exists.

- [ ] Use the current structured logind option in `modules/powerbutton.nix`: `services.logind.settings.Login.HandlePowerKey = "poweroff"`. The old `services.logind.powerKey` spelling is currently a renamed compatibility option, so this is migration work rather than an urgent breakage.

- [ ] Remove packages already installed by their service modules. Current NixOS modules add the CLI/package for both `services.tailscale.enable` and `services.power-profiles-daemon.enable`, making the matching `environment.systemPackages` entries redundant. Review `pulseaudio` in `modules/common.nix` as well: PipeWire's PulseAudio compatibility is enabled on the desktop hosts, so installing the PulseAudio daemon package globally is confusing unless a specific CLI from it is required.

- [ ] Refactor `home/flake.nix` around a small `mkHome` function. The three configurations repeat `pkgs`, module lists, and almost-identical `extraSpecialArgs`; the repetition caused the broken `tv` output. Derive the platform from `pkgs.stdenv.hostPlatform.system` instead of passing a separate `system` argument, and export reusable profile modules without forcing consumers to know every input argument.

- [ ] Split `home/modules/common.nix` into actual common, development, hardware/device, and GUI/Wayland package sets. The `headless` and `tv` profiles currently inherit compilers, Node/Rust toolchains, language servers, `wl-clipboard`, MTP tools, and workstation-only scripts. Smaller role modules will make the standalone profiles meaningful without changing repository boundaries.

- [ ] Make dotfiles inclusion explicit enough to review. `builtins.readDir "${dotfiles}/.config"` automatically deploys every new top-level config directory except `Code`, which makes an innocent dotfiles addition silently affect all Home Manager profiles. Keep sources in the dotfiles repo, but use an allowlist/profile-specific lists and `xdg.configFile` for XDG paths. Document why `Code` is excluded and which files are intentionally stow-only.

- [ ] Remove duplicate deployment of `.local/scripts`. `home/modules/common.nix` both links the whole directory to `~/.local/scripts` and wraps `kindle`/`switch-audio` into `home.packages`. Choose one executable interface. If wrappers remain, use `writeShellApplication` with declared `runtimeInputs`; place hardware-specific `switch-audio` only in the PC profile rather than every profile.

- [ ] Replace the imperative bat cache activation with Home Manager's `programs.bat` module. Point `programs.bat.themes.Material-Darker.src` at the vendored theme in the dotfiles input and let the module manage installation/cache behavior. This keeps the actual theme in dotfiles and removes an unconditional mutable `home.activation` command.

- [ ] Use Home Manager's service options while keeping configs in dotfiles. `services.dunst.enable` accepts `configFile`, and `programs.waybar` has `systemd.enable`, `settings`, and `style` options. Point those options to the classic config files instead of maintaining hand-written units. This removes the hard-coded `WAYLAND_DISPLAY=wayland-1`, starts services on the graphical-session target, and supplies restart triggers when config sources change.

- [ ] Fix invalid/brittle executable paths and missing unit dependencies in dotfiles. `dunstrc` uses `/usr/bin/dmenu` and `/usr/bin/xdg-open`, and Zellij uses `/usr/bin/nvim`; use commands from `PATH` or Nix store paths supplied by Home Manager. `.config/systemd/user/swaybg.service` references the untracked `%h/.local/scripts/set_swaybg.sh`; either add/package that script and manage the service declaratively, or remove the dead unit.

- [ ] Deduplicate `home/modules/de.nix` and `de-light.nix`. Extract shared fonts, GTK/cursor configuration, MIME associations, and common applications, then layer full/light packages. MIME defaults must be desktop-file IDs such as `*.desktop`, not executable names (`papers`, `qimgv`, `calibre`); use `xdg.mimeApps.defaultApplicationPackages` or verify the installed desktop IDs. `calibre` is not installed by either module despite being selected for EPUB.

- [ ] Modernize `home/setup.sh`. It uses legacy `nix-shell -p home-manager`, which can select a Home Manager version unrelated to the flake lock, and it supports only `goldan`. Expose the locked Home Manager CLI as a package/app or invoke an explicitly pinned CLI, use strict shell mode and safe quoting, accept a profile argument, and avoid a dotfiles override that writes an absolute lock path.

- [ ] Rework `scripts/update.sh` so it updates intentionally. Use strict shell mode; avoid `cd ... && \\` after `set -e`; do not combine lock-writing updates with local overrides; and accept optional input names using the current `nix flake update <input>...` syntax. Keep the leaf-to-root order (dotfiles if it remains a flake, then Home Manager, then NixOS), and print which lock files changed. Do not update submodule commits implicitly.

- [ ] Turn long-running compositor commands into user services. Hyprland currently starts a Python HTTP server directly from `hyprland.conf`; Sway uses `exec_always` for an infinite subscription loop, which can spawn duplicates on each reload. Define Home Manager user services tied to the graphical session, with Nix store executable paths, restart policy, and logs.

- [ ] Make host/device-specific dotfiles data explicit. Hypr monitor selection is currently commented out while `monitor_manager.sh` probes DMI data, Waybar hard-codes `intel_backlight`, Dunst hard-codes monitor 1, and `switch-audio.sh` hard-codes one PC's sink IDs. Select machine fragments from the corresponding Home Manager profile or generate a tiny machine include; do not push these values into the generic dotfiles set used by headless/TV profiles.

- [ ] Make the shell scripts consistently defensive. Add strict mode where appropriate, usage/default cases, dependency/error checks, and safe arrays/quoting. Notable cases are the global state and `ls`/word-splitting in `.zsh/scripts/plugin_utils.sh`, the command string in `launch_wezterm.sh`, silent invalid arguments in `volume.sh` and `switch-audio.sh`, unquoted `find` in `.zshrc`, and unnecessary `kill -9` in `lock_screen.sh`. Keep scripts that are deliberately Bash- or Zsh-specific labelled accordingly.

- [ ] Create the screenshot directory declaratively (for example with a Home Manager `home.file`/activation-safe directory mechanism or an XDG user directory) before the three Hyprland screenshot bindings write to `~/.screenshots`. The current commands fail when the directory has not already been created.

- [ ] Restore deterministic Neovim parser/plugin compatibility. `treesitter.lua` installs parsers and runs `:TSUpdate` outside Nix, while Home Manager installs a nightly Neovim. Either package the required parsers with the selected Neovim package or pin their revisions alongside `lazy-lock.json`. Replace archived `folke/neodev.nvim` with `folke/lazydev.nvim`, and replace deprecated `vim.loop` with `vim.uv` in `init.lua`.

- [ ] Escape Telescope-selected paths before constructing `:tabedit` commands in `telescope.lua`; spaces, `|`, and other Ex-special characters currently make selections fail or be interpreted as commands. Prefer the structured `vim.cmd` API or `vim.fn.fnameescape`.

## LOW

- [ ] Add concise architecture/operation documentation. Root `README.md` should list valid NixOS targets, recursive submodule setup, rebuild/update behavior, and the three-repository relationship. `home/README.md` should list standalone profiles and activation commands. The dotfiles README should distinguish plain-Stow use from Home Manager use instead of prescribing Cargo/APT/Bob steps that the Nix configuration already replaces.

- [ ] Resolve the Stow documentation contradiction. `home/dotfiles/README.md` says `stow --no-folding .`, but `.stow-local-ignore` excludes `.zshrc`, the main shell configuration. Either explain how `.zshrc` is installed separately or stop ignoring it. Keep `.gitmatr` only if `git-matr` uses it as a repository marker; otherwise replace the placeholder with documented detection.

- [ ] Prefer HTTPS submodule URLs for public repositories in both `.gitmodules` files, unless SSH-only cloning is a deliberate requirement. HTTPS makes recursive cloning work on fresh machines without preconfigured GitHub SSH credentials and does not compromise the repositories' standalone nature.

- [ ] Consolidate repeated flake cache configuration comments. `flake.nix.nixConfig` helps evaluation/build users before activation, while `modules/common.nix.nix.settings` configures the installed daemon, so the duplication is defensible. Document that distinction and keep the key lists synchronized rather than deleting either blindly.

- [ ] Move repeated `nix.settings.experimental-features = [ "nix-command" "flakes" ];` from each host into one shared module and fix spacing. This is configuration-wide behavior, not host-specific behavior.

- [ ] Replace `pkgs.system` with `pkgs.stdenv.hostPlatform.system` in `modules/hyprland.nix` and `home/modules/neovim.nix`. Then remove now-unused `system`, `config`, `lib`, and `pkgs` module arguments throughout the Nix files. This reduces accidental coupling and follows current platform terminology.

- [ ] Use modern derivation helpers for the two tiny custom packages. In `modules/nfancurve.nix` and `home/modules/matr.nix`, prefer `stdenvNoCC`, `install -Dm755`, `hash` instead of the legacy `sha256` attribute, and `lib.getExe`/`lib.getExe'` when referencing packaged executables. Preserve the pinned revisions.

- [ ] Clean stale/dead configuration only after confirming it is not used outside this checkout: `home/modules/zen-browser.nix` and its flake input are never imported; `home/modules/swaync.nix` is never imported; `hypr/scripts/monitor_manager.sh` is referenced only by commented lines; `.zsh/machines/thinkpad.sh` is never sourced; and the alternate Neovim theme is commented out. Removing these would be reasonable, but their current state is not harmful enough to justify assumptions.

- [ ] Remove no-op or misleading settings/comments: `programs.zsh.enable = false` and `programs.neovim.enable = false` in system common; the “For some reason” comments above required Home Manager state versions; the Neovim LSP comment claiming servers are automatically installed (there is no Mason); the empty nvim-lint configuration; and large untouched Kickstart debug/tutorial blocks that obscure active settings.

- [ ] Update current plugin APIs during the next Neovim cleanup. Use the current which-key group API instead of legacy `register`, fix Neo-tree key specs so `desc` is a field rather than a third nested table, and update the health check's old minimum version/message to match the nightly version actually selected. These are maintenance items after the lockfile/reproducibility work.

- [ ] Reduce duplicate WezTerm configuration by extracting shared color, font, key, bell, and hostname logic into one Lua module required by both `wezterm.lua` and `wezterm-hyprland.lua`. Remove unused pane locals in the editor-layout callback. Keep separate entry points if their behavior is intentionally different.

- [ ] Review font declarations. Dunst requests `Fira Mono` and Hyprlock requests `Noto Sans`, while Home Manager explicitly installs Roboto variants. Install the requested fonts or standardize configs on fonts already owned by the profile; do not rely on incidental transitive fonts.

- [ ] Review Waybar for stale selectors and device assumptions. Its CSS contains many selectors for modules absent from `config.jsonc`, the config has empty click commands, and microphone actions hard-code source `0` instead of the default source. Removing proven-dead CSS and using `@DEFAULT_SOURCE@` will make the file easier to maintain.

- [ ] Add provenance/licensing notes for the vendored `Material-Darker.tmTheme`; the file names its author but the repository does not state its source revision or license. The theme itself otherwise does not need structural changes.

- [ ] Use one consistent Nix formatter and style in a dedicated formatting-only change. Current files mix brace placement, spacing, `with pkgs`, and long single-line argument sets. Do not combine this with functional refactors, and do not hand-edit lock files.

- [ ] Keep all `system.stateVersion` and `home.stateVersion` values unchanged unless a release-note-driven migration is intentionally performed. They are compatibility versions, not the installed NixOS/Home Manager version. The generated `hosts/*/hardware-configuration.nix` files likewise need no structural refactor; only change them when hardware/storage reality changes.

- [ ] Keep the root-level `rebuild.sh` location unless all operational entry points are moved together. The request refers to `scripts/rebuild.sh`, but the actual file is `rebuild.sh`; consistency could also be achieved by changing the README/requested path rather than moving a well-known top-level command.

## Reference material used

- [Nix flake reference: path inputs, non-flake inputs, and nested input paths](https://nix.dev/manual/nix/latest/command-ref/new-cli/nix3-flake)
- [Current `nix flake update` syntax](https://nix.dev/manual/nix/latest/command-ref/new-cli/nix3-flake-update.html)
- [Home Manager as a NixOS module (`useGlobalPkgs`, `useUserPackages`, `extraSpecialArgs`)](https://nix-community.github.io/home-manager/installation/nixos.html)
- [Home Manager flake usage and standalone/embedded modes](https://nix-community.github.io/home-manager/nix-flakes.html)
- [Home Manager Dunst options](https://nix-community.github.io/home-manager/options/home-manager/services/dunst.html)
- [Home Manager Waybar options](https://nix-community.github.io/home-manager/options/home-manager/programs/waybar.html)
- [Home Manager bat options](https://nix-community.github.io/home-manager/options/home-manager/programs/bat.html)
- [Home Manager XDG MIME options](https://nix-community.github.io/home-manager/options/home-manager/xdg.html)
- [Current NixOS logind option compatibility mappings](https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/system/boot/systemd/logind.nix)
- [Current NixOS Tailscale module](https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/networking/tailscale.nix)
- [Current NixOS power-profiles-daemon module](https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/hardware/power-profiles-daemon.nix)
- [Current systemd-boot `configurationLimit` option](https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/system/boot/loader/systemd-boot/systemd-boot.nix)
- [Neovim deprecated API list](https://neovim.io/doc/user/deprecated/)
- [neodev.nvim EOL and lazydev.nvim recommendation](https://github.com/folke/neodev.nvim)
- [lazy.nvim lockfile feature](https://github.com/folke/lazy.nvim)
