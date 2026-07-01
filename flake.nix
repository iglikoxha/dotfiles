{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # tmux config, pulled from its own remote repo (not a flake)
    tmux-config = {
      url = "github:iglikoxha/tmux";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      tmux-config,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfreePredicate =
          pkg:
          builtins.elem (nixpkgs.lib.getName pkg) [
            "claude-code"
            "terraform"
          ];
      };
    in
    {
      homeConfigurations."igli" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home.nix ];
        extraSpecialArgs = { inherit tmux-config; };
      };
    };
}
