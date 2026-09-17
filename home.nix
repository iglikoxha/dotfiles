{
  config,
  pkgs,
  pkgs-terraform,
  tmux-config,
  username,
  ...
}:
{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    # everyday basics
    curl
    wget
    unzip
    tree
    dos2unix # convert CRLF/LF line endings (handy on WSL)

    # modern CLI tools
    ripgrep # rg — fast grep (telescope's live-grep shells out to it)
    fd # fast find (telescope's file finder)
    bat # cat with syntax highlighting
    fzf # fuzzy finder

    # editor (LazyVim)
    neovim
    lazygit # git TUI, bound to <leader>gg in LazyVim
    tree-sitter # tree-sitter CLI, builds grammars

    # C toolchain — treesitter grammar compiles, Mason/native plugin builds
    gcc
    gnumake

    # terminal
    tmux # terminal multiplexer (config + plugins managed by its own repo via TPM)
    mosh # mobile shell — ssh replacement that survives roaming/sleep

    # node toolchain
    fnm # runtime node version manager (nvm-style: fnm install/use, reads .nvmrc)
    pnpm # node package manager (self-contained; project scripts still run on fnm's node)

    # python toolchain
    (python3.withPackages (ps: [ ps.pip ])) # interpreter + pip on PATH (Mason needs pip; Nix omits it by default)
    uv # python package/venv manager (used for actual python work)

    # rust toolchain
    cargo
    rustc # cargo shells out to rustc; nixpkgs ships them as separate pkgs

    # infrastructure
    pkgs-terraform.terraform # IaC CLI, pinned in flake.nix so flake updates don't rebuild it
    awscli2 # `aws` CLI v2
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

  # starship prompt — installs starship only. Bash isn't managed by home-manager,
  # so the `starship init bash` line lives in ~/.bashrc (see README step 4).
  # Config started from the upstream "Nerd Font Symbols" preset and is kept as a
  # toml file (too many glyphs to sanely express as nix attrs). Customized on top:
  # connector words ("on", "via", ...) stripped, clouds/username/package disabled,
  # uv-aware python, and the Claude Code status line profile.
  programs.starship.enable = true;
  xdg.configFile."starship.toml".source = ./starship.toml;

  home.enableNixpkgsReleaseCheck = false;
}
