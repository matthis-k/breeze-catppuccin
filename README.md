# Breeze Catppuccin

<p align="center">
    <img src="/assets/demo.png" />
</p>

## Description

Just like KDE Breeze Dark cursor pack, but recolored with Catppuccin Mocha accents.

The flake exposes a shared prebuild at `packages.${system}.build` and per-accent packages at `packages.${system}.catppuccin-breeze.<accent>`.

`build` generates all standard Catppuccin accents once, and the per-accent packages point at those prebuilt theme directories:

`rosewater flamingo pink mauve red maroon peach yellow green teal sky sapphire blue lavender`

The original cursor design and generator scripts come from upstream Breeze and the original `desyatkoff/breeze-catppuccin` recolor work.

## Nix

Build one of the packaged variants directly from the flake:

```nix
inputs.breeze-catppuccin.packages.${pkgs.system}.catppuccin-breeze.mauve
```

Or prebuild every accent in one shot:

```bash
nix build .#build
```

## Manual Installation

Run the installer script:

```Shell
bash <(curl -fsSL https://raw.githubusercontent.com/matthis-k/breeze-catppuccin/main/install.sh)
```

The script builds `.#build` and copies every generated theme into `~/.local/share/icons`.

Then, go to System Settings -> Appearance & Style -> Colors & Themes -> Cursors -> `Breeze-Catppuccin-<accent>` -> Apply

And now your cursor looks exactly like Breeze but the colors are matching with your Catppuccin-colored rice/theme :3
