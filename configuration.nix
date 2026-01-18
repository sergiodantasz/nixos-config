{ config, pkgs, ... }:

let
  home-manager = builtins.fetchTarball https://github.com/nix-community/home-manager/archive/release-25.11.tar.gz;
in
{
  imports = [
    ./hardware-configuration.nix
    (import "${home-manager}/nixos")
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "sergio-nixos";
  networking.networkmanager.enable = true;

  nixpkgs.config.allowUnfree = true;

  fileSystems."/srv/Files" = {
    device = "/dev/disk/by-id/wwn-0x5000039422600d57-part1";
    fsType = "ext4";
  };

  time.timeZone = "America/Fortaleza";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
    inputMethod = {
      enable = true;
      type = "ibus";
    };
  };

  console.keyMap = "br-abnt2";

  services = {
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;

    xserver = {
      enable = true;

      xkb = {
        layout = "br";
        variant = "";
      };

      excludePackages = [ pkgs.xterm ];
    };
  };

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
    showtime
    yelp
  ];

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.printing.enable = false;

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    jetbrains-mono
  ];

  # Don't forget to set a password with ‘passwd’
  users.users.sergio = {
    isNormalUser = true;
    description = "Sérgio Dantas";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;
  programs.firefox.enable = false;
  programs.appimage.enable = true;
  services.flatpak.enable = true;
  documentation.nixos.enable = false;

  environment.systemPackages = with pkgs; [
    curl
    git
    gnutar
    wget
    zsh
  ];

  system.stateVersion = "25.11";

  home-manager.users.sergio = { pkgs, ... }: {
    nixpkgs.config.allowUnfree = true;

    home.sessionVariables = {
      PYTHON_KEYRING_BACKEND = "keyring.backends.null.Keyring";
    };

    home.packages = with pkgs; [
      discord
      microsoft-edge
      qbittorrent
      flatpak # Don't forget to add the flathub repo
      anki
      obsidian
      texliveFull
      texstudio
      spotify
      vlc
      gh
      bun
      nodejs_24
      poetry # Don't forget to set virtualenvs.in-project to true
      python313
      uv
      deno
      gnomeExtensions.appindicator
      gnomeExtensions.blur-my-shell
      gnomeExtensions.rounded-window-corners-reborn
    ];

    dconf.settings = {
      "org/gnome/shell" = {
        disable-user-extensions = false;
        enabled-extensions = [
          pkgs.gnomeExtensions.appindicator.extensionUuid
          pkgs.gnomeExtensions.blur-my-shell.extensionUuid
          pkgs.gnomeExtensions.rounded-window-corners-reborn.extensionUuid
        ];
      };

      "org/gnome/TextEditor" = {
        highlight-current-line = true;
        indent-style = "space";
        restore-session = false;
        show-line-numbers = true;
        # How can I set tab-width = uint32 2?
      };

      "org/gnome/Console" = {
        custom-font = "FiraCode Nerd Font Mono 11";
        use-system-font = false;
      };
      
      "org/gnome/desktop/sound" = {
        allow-volume-above-100-percent = true;
      };

      "org/gnome/desktop/wm/preferences" = {
        button-layout = ":minimize,maximize,close";
      };

      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
        ];
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        name = "Open Console";
        command = "kgx";
        binding = "<Control><Alt>t";
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
        name = "Open Files";
        command = "nautilus";
        binding = "<Super>f";
      };

      "org/gnome/desktop/wm/keybindings" = {
        show-desktop = [ "<Super>d" ];
      };
    };

    programs.zsh = {
      enable = true;

      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      shellAliases = {
        nixrbs = "sudo nixos-rebuild switch";
        nixrbsu = "sudo nixos-rebuild switch --upgrade";
        nixcfg = "sudo nano /etc/nixos/configuration.nix";
      };
    };

    programs.starship = {
      enable = true;
      enableZshIntegration = true;
    };

    # Don't forget to create and set SSH key on GitHub
    programs.git = {
      enable = true;

      settings = {
        user.name = "Sérgio Dantas";
        user.email = "sergiodnts828@gmail.com";
        init.defaultBranch = "main";
        gpg.format = "ssh";
      };

      signing = {
        key = "/home/sergio/.ssh/id_ed25519.pub";
        signByDefault = true;
      };
    };

    home.stateVersion = "25.11";
  };
}
