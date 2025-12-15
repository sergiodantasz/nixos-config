{ config, pkgs, ... }:

let
  home-manager = builtins.fetchTarball https://github.com/nix-community/home-manager/archive/release-25.11.tar.gz;
in
{
  imports = [
    ./hardware-configuration.nix
    (import "${home-manager}/nixos")
  ];
  
  ### BOOT & SYSTEM BASE

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking & Hostname
  networking.hostName = "sergio-nixos";
  networking.networkmanager.enable = true;
  
  # Kernel / Hardware (External drives & general configs)
  nixpkgs.config.allowUnfree = true; # Allow unfree packages globally

  fileSystems."/srv/Files" = {
    device = "/dev/disk/by-id/wwn-0x5000039422600d57-part1";
    fsType = "ext4";
  };
  
  ### LOCALE & TIME

  time.timeZone = "America/Fortaleza";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_NAME = "pt_BR.UTF-8";
    LC_NUMERIC = "pt_BR.UTF-8";
    LC_PAPER = "pt_BR.UTF-8";
    LC_TELEPHONE = "pt_BR.UTF-8";
    LC_TIME = "pt_BR.UTF-8";
  };
  
  # Configure keymap (TTY)
  console.keyMap = "br-abnt2";
  
  ### GUI (GNOME) & AUDIO
  
  # X11 & GNOME
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    
    # Keymap configuration for X11/GNOME
    xkb = {
      layout = "br";
      variant = "";
    };

    # Exclude default xterm
    excludePackages = [ pkgs.xterm ];
  };
  
  # Remove GNOME Bloatware
  environment.gnome.excludePackages = with pkgs; [
    decibels
    epiphany
    file-roller
    geary
    gnome-calendar
    gnome-characters
    gnome-connections
    gnome-contacts
    gnome-font-viewer
    gnome-logs
    gnome-maps
    gnome-music
    gnome-photos
    gnome-tour
    gnome-weather
    nixos-render-docs
    seahorse
    simple-scan
    totem
    yelp
  ];

  # Audio (Pipewire)
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  
  # Printing (Disabled)
  services.printing.enable = false;
  
  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code # Manually set as console font
    jetbrains-mono
  ];
  
  ### USERS & SYSTEM PACKAGES

  # Don't forget to set a password with ‘passwd’
  users.users.sergio = {
    isNormalUser = true;
    description = "Sérgio Dantas";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh; # Explicitly set ZSH as the login shell
  };
  
  # Global Program Settings
  programs.zsh.enable = true; # Required for the system to recognize ZSH
  programs.firefox.enable = false; # Disable default Firefox
  programs.appimage.enable = true;
  documentation.nixos.enable = false;

  # Essential SYSTEM Packages (Available to root and all users)
  environment.systemPackages = with pkgs; [
    curl
    git
    gnutar
    wget
    zsh
  ];
  
  system.stateVersion = "25.11";
  
  ### HOME MANAGER (User Configuration)

  home-manager.users.sergio = { pkgs, ... }: {
    # Allow unfree packages within home-manager context
    nixpkgs.config.allowUnfree = true;
  
    ### USER PACKAGES
    
    home.packages = with pkgs; [
      # Browsers & Internet
      discord
      microsoft-edge
      qbittorrent
      telegram-desktop
      ungoogled-chromium

      # Productivity & Study
      anki
      obsidian
      texliveFull
      texstudio

      # > Media
      spotify
      stremio
      vlc

      # > Development & CLI
      bun
      nodejs_24
      poetry
      python313
      uv
      
      # > GNOME Extensions
      gnomeExtensions.appindicator
    ];
    
    ### PROGRAM CONFIGURATIONS
    
    # GNOME Settings (dconf)
    dconf.settings = {
      "org/gnome/shell" = {
        disable-user-extensions = false;
        enabled-extensions = [ pkgs.gnomeExtensions.appindicator.extensionUuid ];
      };
    };
    
    # Shell (ZSH)
    programs.zsh = {  
      enable = true;
      
      # ZSH plugins
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      
      # Aliases
      shellAliases = {
        nixrbs = "sudo nixos-rebuild switch";
        nixrbsu = "sudo nixos-rebuild switch --upgrade";
        nixcfg = "sudo nano /etc/nixos/configuration.nix";
      };
    };
    
    # Prompt (Starship)
    programs.starship = {
      enable = true;
      enableZshIntegration = true;
    };
    
    # Editor (VS Code)
    programs.vscode = {
      enable = true;
    };
  
    # Version control (Git)
    # Don't forget to create and set SSH key on GitHub
    programs.git = {
      enable = true;
      
      userName = "Sérgio Dantas";
      userEmail = "sergiodnts828@gmail.com";
      
      signing = {
        key = "/home/sergio/.ssh/id_ed25519.pub";
        signByDefault = true;
      };
      
      extraConfig = {
        init.defaultBranch = "main";
        gpg.format = "ssh";
      };
    };

    home.stateVersion = "25.11";
  };
}
