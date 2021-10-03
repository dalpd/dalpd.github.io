{ compiler ? "ghc8104" }:

let
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs { };

  inherit (pkgs.haskell.lib) dontCheck;

  baseHaskellPkgs = pkgs.haskell.packages.${compiler};

  # TODO(dalp): Pull this overlay out into its own file
  myHaskellPackages = baseHaskellPkgs.override {
    overrides = hself: hsuper: {
      post-office = hself.callCabal2nix "post-office" (./.) { };

      ########################################################################
      # Version overrides
      ########################################################################

      ########################################################################
      # Disabled test suites
      ########################################################################
    };
  };

  shell = myHaskellPackages.shellFor {
    packages = p: with p; [
      post-office
    ];

    buildInputs = with pkgs.haskellPackages; [
      cabal-install
      ghcid
      ormolu
      hlint
      pkgs.niv
      pkgs.nixpkgs-fmt
      # hakyll is here mainly for initialization
      # $ hakyll-init <name>
      myHaskellPackages.hakyll
    ];

    libraryHaskellDepends = [
    ];

    shellHook = ''
      set -e
      hpack
      set +e
    '';
  };

in
{
  inherit shell;
  post-office = myHaskellPackages.post-office;
}
