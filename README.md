# Nixos Config

To activate:

```bash
sudo nixos-rebuild switch --flake ~/nixos-config#vm
```

To update:

```bash
cd <proj_root>/home
nix flake update --override input dotfiles path:<full_path_to_dotfiles>

cd <proj_root>/
nix flake update --override input home-config path:<full_path_to_home-config>
```
