{ config, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable OpenGL
  hardware.graphics = {
    enable = true;
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {

    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    open = true;

    # Enable the Nvidia settings menu,
	# accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  networking.hostName = "nixos"; # Define your hostname.
  #networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Rome";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "it_IT.UTF-8";
    LC_IDENTIFICATION = "it_IT.UTF-8";
    LC_MEASUREMENT = "it_IT.UTF-8";
    LC_MONETARY = "it_IT.UTF-8";
    LC_NAME = "it_IT.UTF-8";
    LC_NUMERIC = "it_IT.UTF-8";
    LC_PAPER = "it_IT.UTF-8";
    LC_TELEPHONE = "it_IT.UTF-8";
    LC_TIME = "it_IT.UTF-8";
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;
  services.xserver = {
    desktopManager = {
      xterm.enable = false;
      xfce.enable = true;
    };
  };
  services.displayManager.defaultSession = "xfce";
  services.xserver.xkb = {
    layout = "it";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "it2";

  # Enable CUPS to print documents.
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  services.printing = {
    enable = true;
    drivers = with pkgs; [
      cups-filters
      cups-browsed
    ];
  };

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Allow flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    git
  ];

  # enable programs and config their settings
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
    '';
  };

  programs.firefox = {
    enable = true;
    package = pkgs.librewolf;
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      Preferences = {
        "cookiebanners.service.mode.privateBrowsing" = 2; # Block cookie banners in private browsing
        "cookiebanners.service.mode" = 2; # Block cookie banners
        "privacy.donottrackheader.enabled" = false;
        "privacy.fingerprintingProtection" = false;
        "privacy.resistFingerprinting" = false;
        "privacy.trackingprotection.emailtracking.enabled" = true;
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.fingerprinting.enabled" =false;
        "privacy.trackingprotection.socialtracking.enabled" = true;
        "sidebar.verticalTabs.enabled" = true;
        "sidebar.verticalTabs" = true;
        "browser.theme.toolbar-theme" = 2;
      };
      ExtensionSettings = {
        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
        };
        "myallychou@gmail.com" = {
          install_url = "https://addons.mozilla.org/it/firefox/addon/youtube-recommended-videos/latest.xpi";
          installation_mode = "force_installed";
        };
        
      };
    };
  };
  environment.etc."firefox/policies/policies.json".target = "librewolf/policies/policies.json";

  programs.git = {
    enable = true;
    config = {
      user.name = "albynotar";
      user.email = "alberto.notarnicola@gmail.com";
    };
  };

  programs.vscode = {
    enable = true;
    defaultEditor = true;

  };
  services.gnome.gnome-keyring.enable = true; # store authlogin

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.alby = {
    isNormalUser = true;
    description = "alberto";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.fish;
    packages = with pkgs; [

      #command line tools
      R
      go
      jq
      bat
      fzf
      git
      vim
      bash
      btop
      curl
      fish
      wget
      htop
      ffmpeg-full
      rustup
      yt-dlp
      testdisk
      fastfetch
      ghostscript
      nixfmt-rfc-style
      # applicationws
      vlc
      gimp3
      ghostty
      bleachbit
      librewolf
      thunderbird
      mkvtoolnix
      obs-studio
      libreoffice
      bitwarden-desktop

      # set up vscode with its extensions
      (vscode-with-extensions.override {
        vscodeExtensions =
          with vscode-extensions;
          [
            # already packaged in nix packages
            # languages
            jnoortheen.nix-ide
            ms-python.python
            ms-python.debugpy
            ms-python.vscode-pylance
            rust-lang.rust-analyzer
            golang.go
            reditorsupport.r
            #utils
            esbenp.prettier-vscode
            codezombiech.gitignore
            tyriar.sort-lines
            tomoki1207.pdf

            # not packaged, manual retrival
            # TO DO packaging
          ]
          ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
            {
              name = "vscode-python-envs";
              publisher = "ms-python";
              version = "1.2.0";
              sha256 = "6QjfJuxqu7sXqlcp3q3T+J9aGsOSu90xoQxdL+G6Fus=";
            }
            {
              name = "r-syntax";
              publisher = "reditorsupport";
              version = "0.1.3";
              sha256 = "grkfkmyERVUkB8kSH+NPd2Mv4WF/h/obw8ebmxPx5zU=";
            }
            {
              name = "string-manipulation";
              publisher = "marclipovsky";
              version = "0.7.43";
              sha256 = "i9DhQZ1sZiMQnEK9kUBbAeq1+CqAyZPk0jb48tGv7yg=";
            }
            {
              name = "ruff";
              publisher = "charliermarsh";
              version = "2025.24.0";
              sha256 = "ijy/ZVhVU1/ZrS1Fu3vuiThcjLuKSqf3lrgl8is54Co=";
            }
            {
              name = "vscode-edit-csv";
              publisher = "janisdd";
              version = "0.11.5";
              sha256 = "0DPp4F+cdLff80XGXYoDiXtoAKKs/wp44qv41qG36dU=";
            }
          ];
      })
    ];
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:
  # tesy commit

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
