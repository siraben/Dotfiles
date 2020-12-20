{ config, lib, currentSystem, ... }:
# To put pkgs in scope in nix repl
# :a (import (import nix/sources.nix).nixpkgs) {}
let
  inherit (builtins) currentSystem;
  inherit (lib.systems.elaborate { system = currentSystem; }) isLinux isDarwin;
  sources = import ../../../nix/sources.nix;
  pkgs = import sources.nixpkgs {
    overlays = [
      (import ./nextcloud-overlay.nix)
      (import sources.nixpkgs-wayland)
      (import sources.emacs-overlay)
    ];
    config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) unfreePackages;
  };
  unfreePackages = [
    "discord"
    "slack"
    "spotify"
    "spotify-unwrapped"
    "zoom-us"
    "faac" # part of zoom
  ];
  # Fork of comma that uses local nix-index if possible.
  comma = import sources.comma { inherit pkgs; };
  gccemacs = (import sources.nix-gccemacs-darwin).emacsGccDarwin;
  nix-bisect = import sources.nix-bisect { inherit pkgs; };
  wrapWeb = pkgs.callPackage ./wrapWeb.nix { };
  wayland-packages = with pkgs; [
    emacsPgtkGcc
    firefox-wayland
    grim
    slurp
    swaylock-fancy
    wlsunset
    wofi
    xdg-desktop-portal-wlr
  ];
  web-shortcuts = with pkgs; [
    (wrapWeb "element" "https://app.element.io")
    (wrapWeb "hn" "https://news.ycombinator.com")
    (wrapWeb "neverssl" "http://neverssl.com")
    (wrapWeb "mastodon" "https://mastodon.social")
  ];
  linuxPackages = with pkgs; [
    anki
    bemenu
    discord
    docker
    docker-compose
    dragon-drop
    evince
    exfat
    feh
    gnome3.cheese
    gnumake
    gnupg
    keepassxc
    killall
    libreoffice
    lightlocker
    msmtp
    musescore
    networkmanager
    nextcloud-client
    nix-update
    offlineimap
    paper-icon-theme
    poppler_utils
    rhythmbox
    rofi
    slack
    spotify
    system-config-printer
    tdesktop
    thunderbird
    tor-browser-bundle-bin
    transmission-gtk
    ungoogled-chromium
    vlc
    whois
    wpa_supplicant
    xorg.xkill
    zoom-us
  ] ++ wayland-packages ++ web-shortcuts;
  darwinPackages = with pkgs; [
    coreutils
    gccemacs
  ];
  sharedPackages = with pkgs; [
    ag
    agda
    alacritty
    aspell
    aspellDicts.en
    aspellDicts.en-computers
    autojump
    bat
    borgbackup
    cabal-install
    cachix
    ccls
    chez
    clang-tools
    clang_10
    cmake
    comma
    coq
    exiftool
    ghc
    github-cli
    graphviz
    guile
    haskellPackages.ghcide
    haskellPackages.haskell-language-server
    hlint
    htop
    jq
    kitty
    ledger
    manix
    mpv
    mu
    niv
    nix-bisect
    nix-index
    nix-prefetch-git
    nixfmt
    nixpkgs-fmt
    nixpkgs-review
    nodePackages.bash-language-server
    nodePackages.javascript-typescript-langserver
    nodePackages.pyright
    nodejs
    python38
    python38Packages.nix-prefetch-github
    ranger
    ripgrep
    rustup
    shellcheck
    stow
    (texlive.combine {
      inherit (texlive) scheme-medium latexmk wrapfig rotfloat capt-of minted fvextra upquote catchfile xstring framed biblatex csquotes;
    })
    the-powder-toy
    tldr
    tmux
    tnef
    tor
    tree
    unzip
    vim
    watch
    youtube-dl
    zathura
    zip
  ];
  darwinShellExtra = ''
    source $HOME/.nix-profile/etc/profile.d/nix.sh
  '';
  linuxShellExtra = "";
  sharedShellExtra = ''
    source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh
  '';
  darwinShellAliases = {
    # useful command to run sequenced after a long command, `nix build; sd`
    sd = "say done";
    # brew bundle, but make it like home manager
    bb-check = "brew bundle check --global --verbose";
    bb-gc = "brew bundle cleanup --global --force";
    bb-switch = "brew bundle install --global --verbose";
    bb-upgrade = "brew bundle install --global --verbose --upgrade";
    # linuxkit-builder.  Unfortunately I'll have to install it
    # imperatively due to it lacking a bootstrap from darwin.
    lb-gc = "rm -rf ~/.cache/nix-linuxkit-builder/";
    lb-init = "nix-linuxkit-configure";
    lb-reset = "lb-stop; lb-gc; lb-init;";
    lb-start = "launchctl stop org.nix-community.linuxkit-builder";
    lb-stop = "launchctl stop org.nix-community.linuxkit-builder";
  };
in
{
  programs.home-manager.enable = true;

  home.username = "siraben";
  home.homeDirectory = if isDarwin then "/Users/siraben" else "/home/siraben";
  home.packages = sharedPackages ++ (lib.optionals isLinux linuxPackages)
    ++ (lib.optionals isDarwin darwinPackages);

  home.sessionVariables = {
    EDITOR = "emacsclient";
  } // (lib.optionalAttrs isLinux {
    XDG_CURRENT_DESKTOP = "sway";
  });

  programs = {
    broot.enable = true;
    git = {
      enable = true;
      userName = "Ben Siraphob";
      userEmail = "bensiraphob@gmail.com";
      extraConfig = {
        pull.rebase = true;
        github.user = "siraben";
      };
    };
    zsh = {
      enable = true;
      enableAutosuggestions = true;
      oh-my-zsh = {
        enable = true;
        theme = "robbyrussell";
        plugins = [ "git" "autojump" ];
      };
      history = {
        size = 100000;
        save = 100000;
      };
      shellAliases = {
        hm = "home-manager";
        hms = "home-manager switch";
        httpcode = ''curl -o /dev/null -s -w "%{http_code}\n"'';
        nb = "nix build";
        nc = "nix channel";
        ncg = "nix-collect-garbage";
        ne = "nix edit";
        nix-review-post = "nix-review pr --post-result";
        nr = "nix repl";
        nrp = "nix repl '<nixpkgs>'";
        ns = "nix-shell";
        tb = "tput bel";
        ix = ''curl -n -F 'f:1=<-' http://ix.io'';
      } // (lib.optionalAttrs isDarwin darwinShellAliases);
      initExtra = lib.concatStringsSep "\n"
        [
          (lib.optionalString isDarwin darwinShellExtra)
          (lib.optionalString isLinux linuxShellExtra)
          sharedShellExtra
        ];
    };
  };

  programs.direnv.enable = true;
  programs.direnv.enableNixDirenvIntegration = true;

  home.stateVersion = "20.09";
}
