{
  config,
  pkgs,
  tmux-config,
  ...
}:
{
  home.username = "igli";
  home.homeDirectory = "/home/igli";
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    # LazyVim core
    neovim
    git
    gcc # C compiler for treesitter & native plugins
    gnumake # make
    curl
    wget

    # LazyVim Mason required
    unzip

    # LazyVim's expected tools
    ripgrep # rg  — telescope grep
    fd # fd  — telescope file find
    lazygit # <leader>gg
    tree-sitter # tree-sitter-cli

    # nice-to-haves
    bat
    fzf
    tree

    # terminal
    tmux # terminal multiplexer (config + plugins managed by its own repo via TPM)

    # node toolchain
    fnm # runtime node version manager (nvm-style: fnm install/use, reads .nvmrc)

    # python toolchain
    (python3.withPackages (ps: [ ps.pip ])) # interpreter + pip on PATH (Mason needs pip; Nix omits it by default)
    uv # python package/venv manager (used for actual python work)

    # rust toolchain (Mason builds some tools via `cargo install`)
    cargo
    rustc # cargo shells out to rustc; nixpkgs ships them as separate pkgs

    # infrastructure
    terraform # IaC CLI (unfree: BUSL — allowlisted in flake.nix)

    # ai
    claude-code # the `claude` CLI
  ];

  programs.git = {
    enable = true;
    settings.user.name = "Igli";
    settings.user.email = "11091751+iglikoxha@users.noreply.github.com";
    settings.init.defaultBranch = "main";
  };

  # tmux config pulled verbatim from the remote repo (flake input) into the XDG
  # config dir. The config is self-contained: it bootstraps TPM and its plugins
  # on first launch, so it works identically on machines without Nix. Nix only
  # provides the tmux binary (and git, used by the bootstrap).
  xdg.configFile."tmux/tmux.conf".source = "${tmux-config}/tmux.conf";

  # starship prompt — installs starship + wires bash init.
  # Config is the upstream "Nerd Font Symbols" preset, kept as a verbatim
  # toml file (too many glyphs to sanely express as nix attrs).
  programs.starship.enable = true;
  xdg.configFile."starship.toml".source = ./starship.toml;

  home.enableNixpkgsReleaseCheck = false;
}
