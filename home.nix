{ config, pkgs, ... }: {
  home.username = "igli";
  home.homeDirectory = "/home/igli";
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    # LazyVim core
    neovim
    git
    gcc          # C compiler for treesitter & native plugins
    gnumake      # make
    curl

    # LazyVim's expected tools
    ripgrep      # rg  — telescope grep
    fd           # fd  — telescope file find
    lazygit      # <leader>gg
    tree-sitter  # tree-sitter-cli

    # nice-to-haves
    bat
    fzf
  ];

  programs.git = {
    enable = true;
    settings.user.name = "Igli";
    settings.user.email = "11091751+iglikoxha@users.noreply.github.com";
    settings.init.defaultBranch = "main";
  };

  home.enableNixpkgsReleaseCheck = false;
}
