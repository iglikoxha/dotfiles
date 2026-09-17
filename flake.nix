{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Terraform is pinned to its own nixpkgs commit. Its BUSL license is unfree, so
    # the NixOS binary cache doesn't build it, and any nixpkgs update that touches
    # Terraform or its dependencies (e.g. the Go toolchain) recompiles it locally.
    # `nix flake update` never moves an input pinned to a commit hash.
    # To upgrade, see "Terraform is pinned" in README.md.
    nixpkgs-terraform.url = "github:nixos/nixpkgs/b1b875982b17dabde9b4a37f3e229e74913e6db3";

    # tmux config, pulled from its own remote repo (not a flake)
    tmux-config = {
      url = "github:iglikoxha/tmux";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-terraform,
      home-manager,
      tmux-config,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      # Terraform only, from the pinned input above (unfree: BUSL license, allowlisted here).
      pkgs-terraform = import nixpkgs-terraform {
        inherit system;
        config.allowUnfreePredicate = pkg: nixpkgs-terraform.lib.getName pkg == "terraform";
      };
      # one home config per machine username; a bare `home-manager switch
      # --flake ~/dotfiles` picks the attribute matching $USER automatically
      mkHome =
        username:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./home.nix ];
          extraSpecialArgs = { inherit tmux-config username pkgs-terraform; };
        };
    in
    {
      homeConfigurations = {
        igli = mkHome "igli";
        dev = mkHome "dev";
      };
    };
}
