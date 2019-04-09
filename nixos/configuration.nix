# configuration.nix
# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # ./sddm.nix
      # ./mktiupgrade.nix
      # ./tilem.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    cleanTmpDir = true;
  };
  nixpkgs.config.allowUnfree = true;

  networking.networkmanager.enable = true;
  networking.hostName = "nixos"; # Define your hostname.
  networking.nameservers = [
    "1.0.0.1"
    "1.1.1.1"
  ];
  swapDevices = [ { device = "/var/swap"; size = 4096; } ];

  sound.enable = true;
  hardware = {
    bluetooth.enable = true;
    facetimehd.enable = true;
    pulseaudio.enable = true;
    pulseaudio.package = pkgs.pulseaudioFull;
  };

  powerManagement.enable = true;
  programs.light.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Bangkok";

  fonts = {
    enableFontDir = true;
    enableCoreFonts = true;
    enableGhostscriptFonts = true;

    fonts = with pkgs; [
      emojione
      noto-fonts
      noto-fonts-cjk
      noto-fonts-extra
      hack-font
      inconsolata
      material-icons
      liberation_ttf
      dejavu_fonts
      terminus_font
      siji
      unifont
    ];
    fontconfig.ultimate.enable = true;
    fontconfig.defaultFonts = {
      monospace = [
        "Hack"
      ];
      sansSerif = [
        "DejaVu Sans"
        "Noto Sans"
      ];
      serif = [
        "DejaVu Serif"
        "Noto Serif"
      ];
    };

  };

  environment = {
    variables = {
      EDITOR = pkgs.lib.mkOverride 0 "emacsclient";
    };
    systemPackages = with pkgs; [
      anki
      arc-theme
      asciinema
      aspell
      aspellDicts.en
      atool
      biber
      binutils
      borgbackup
      brave
      cabal-install
      cargo
      coq
      emacs
      evince
      exfat
      ffmpeg
      firefox
      font-awesome-ttf
      gcc
      gforth
      ghc
      gimp
      git
      gnumake
      gnupg
      gparted
      gpicview
      guile
      htop
      i3-gaps
      imagemagick7
      inkscape
      keepassxc
      killall
      kitty
      libreoffice
      lightlocker
      lynx
      mediainfo
      mpd
      mpv
      msmtp
      mu
      networkmanager
      nextcloud-client
      nitrogen
      offlineimap
      okular
      pandoc
      paper-icon-theme
      polybar
      powertop
      python3
      ranger
      redshift
      rhythmbox
      rofi
      rustc
      rustfmt
      rxvt_unicode
      scrot
      silver-searcher
      smlnj
      smlnj
      stow
      system-config-printer
      terminator
      texlive.combined.scheme-full
      the-powder-toy
      thunderbird
      tmux
      tor-browser-bundle-bin
      transmission-gtk
      tree
      unzip
      urxvt_font_size
      vim
      vlc
      wget
      whois
      wpa_supplicant
      xss-lock
      youtube-dl
      zathura
      zile
      zip
      zsh
    ];
  };
  # nextcloud-client = pkgs.nextcloud-client.override { withGnomeKeyring = true; libgnome-keyring = pkgs.gnome3.libgnome-keyring; };

  programs.zsh.enable = true;
  programs.zsh.promptInit = ""; # Clear this to avoid a conflict with oh-my-zsh

  services.redshift = {
    enable = true;
    latitude = "13";
    longitude = "100";
    provider = "manual";
    temperature.day = 6500;
    temperature.night = 3000;
    brightness.day = "1";
    brightness.night = "1";
  };

  nixpkgs.config.packageOverrides = pkgs: {
    polybar = pkgs.polybar.override {
      alsaSupport = true;
      i3GapsSupport = true;
      # githubSupport = true;
      mpdSupport = true;
    };
    emacs = pkgs.emacs.override {
     imagemagick = pkgs.imagemagick;
    };
  };


  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = with pkgs; [
    brlaser
    gutenprint
    gutenprintBin
  ];


  services.gnome3.gnome-keyring.enable = true;

  services.xserver = {
    enable = true;
    
    displayManager.lightdm = {
     enable = true;
     greeters.gtk.extraConfig = ''
       xft-dpi=192
     '';
    };
    xkbOptions = "ctrl:nocaps";
    libinput.enable = true;
    layout = "us";
    
    desktopManager = {
      default = "xfce";
      xterm.enable = false;
      xfce = {
        enable = true;
        noDesktop = true;
        enableXfwm = false;
      };
    };
    windowManager = {
      default = "i3";
      i3 = {
        enable = true;
        package = pkgs.i3-gaps;
      };
    };
  };

  # services.xserver.desktopManager.gnome3.enable = true;
  # services.xserver.displayManager.gdm.enable = true;

  users = {
  # Define a user account. Don't forget to set a password with ‘passwd’.
    users.siraben = {
      shell = pkgs.zsh;
      isNormalUser = true;
      home = "/home/siraben";
      description = "Ben Siraphob";
      extraGroups = [ "wheel" "networkmanager" ];
    };
  };

  nix.gc.automatic = true;
  nix.gc.dates = "daily";
  nix.gc.options = "--delete-older-than 7d";

  # mine.workstation.recap.enable = true;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.09"; # Did you read the comment?

}

