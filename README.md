# dotfiles

Nix [home-manager](https://github.com/nix-community/home-manager) config: CLI tools, git, starship prompt, tmux (config pulled from [iglikoxha/tmux](https://github.com/iglikoxha/tmux) as a flake input — TPM bootstraps itself on first tmux launch).

## New machine setup

### 1. Install Nix (with flakes)

```sh
curl -fsSL https://install.determinate.systems/nix | sh -s -- install
```

The [Determinate installer](https://install.determinate.systems) enables flakes out of the box. With the official installer instead, add `experimental-features = nix-command flakes` to `/etc/nix/nix.conf`.

### 2. Clone and activate

```sh
git clone https://github.com/iglikoxha/dotfiles.git ~/dotfiles
nix run github:nix-community/home-manager -- switch --flake ~/dotfiles
```

`home-manager switch` picks the `homeConfigurations` entry matching `$USER`. If this machine's username isn't in the list yet, add a line in `flake.nix` first:

```nix
homeConfigurations = {
  igli = mkHome "igli";
  ...
  newuser = mkHome "newuser";
};
```

After the first activation, home-manager is installed and the command is just:

```sh
home-manager switch --flake ~/dotfiles
```

### 3. Neovim config

Lives in its own repo: [iglikoxha/nvim](https://github.com/iglikoxha/nvim).

```sh
git clone https://github.com/iglikoxha/nvim.git ~/nvim
mkdir -p ~/.config
ln -s ~/nvim ~/.config/nvim
```

If `~/.config/nvim` already exists, move it aside first (`mv ~/.config/nvim ~/.config/nvim.bak`) — otherwise `ln -s` drops the link *inside* it.

### 4. Shell setup (`~/.bashrc`)

`.bashrc` isn't managed by home-manager; add these by hand:

```sh
# fnm (node version manager) — auto-switches node on cd via .nvmrc/.node-version
if command -v fnm >/dev/null 2>&1; then
  eval "$(fnm env --use-on-cd)"
fi

# starship prompt
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init bash)"
fi
```

### 5. Install a node version

fnm ships without any node installed — `node` won't be on PATH until you install one and make it the default (used whenever a project has no `.nvmrc`):

```sh
fnm install 24
fnm default 24
```

## Not managed here

- **Nerd Font** — the starship preset needs one, set in the terminal emulator (on WSL: Windows Terminal's font setting; on native Linux install one, e.g. from [nerdfonts.com](https://www.nerdfonts.com)).
- **Docker** (native Linux) — the daemon is a system service, install the engine per the [official guide](https://docs.docker.com/engine/install/ubuntu/) and add yourself to the docker group (`sudo usermod -aG docker $USER`)
