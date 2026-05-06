# Breeze Catppuccin

<p align="center">
    <img src="/assets/demo.png" />
</p>

## Description

Just like KDE Breeze Dark cursor pack, but recolored with Catppuccin Mocha accents.

The flake exposes a checked-in prebuilt bundle at `packages.${system}.build` and per-accent packages at `packages.${system}.catppuccin-breeze.<accent>`.

`build` copies the committed theme assets without rerunning Inkscape, and the per-accent packages point at those prebuilt theme directories:

`rosewater flamingo pink mauve red maroon peach yellow green teal sky sapphire blue lavender`

If you need to regenerate the assets from the SVG sources, use `packages.${system}.buildFromSource`.

The original cursor design and generator scripts come from upstream Breeze and the original `desyatkoff/breeze-catppuccin` recolor work.

## Nix

Build one of the packaged variants directly from the flake:

```nix
inputs.breeze-catppuccin.packages.${pkgs.system}.catppuccin-breeze.mauve
```

Or copy every checked-in accent into the Nix store in one shot:

```bash
nix build .#build
```

To regenerate the checked-in assets from source instead:

```bash
nix build .#buildFromSource
```

## Manual Installation

Run the installer script:

```Shell
bash <(curl -fsSL https://raw.githubusercontent.com/matthis-k/breeze-catppuccin/main/install.sh)
```

The script builds `.#build` and copies every generated theme into `~/.local/share/icons`.

Then, go to System Settings -> Appearance & Style -> Colors & Themes -> Cursors -> `Breeze-Catppuccin-<accent>` -> Apply

And now your cursor looks exactly like Breeze but the colors are matching with your Catppuccin-colored rice/theme :3
