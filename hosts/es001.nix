### es001
{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
    ];

  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  networking.hostName = "nix-es001"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/Madrid";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;


  

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # hardware.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.naiel = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      tree
    ];
  };

  # programs.firefox.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    python3Minimal
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;



  services.moosefs.masterHost = "192.168.0.7";
  services.moosefs.master.enable = true;
  services.moosefs.master.exports = [
    "* / rw,alldirs,admin,maproot=0:0"
    "* . rw"
  ];

  services.moosefs.chunkserver.enable = true;
  services.moosefs.chunkserver.hdds = [
    "/srv/disk001"
    "/srv/disk004"
  ];
  services.moosefs.client.enable = true;
  fileSystems."/mnt/storage" =
    { device = "127.0.0.1:/";
      fsType = "moosefs";
      options = [ "_netdev" ];
    };


  services.httpd.enable = true;

  services.httpd.virtualHosts."moosefs.arpa" = {
    listen = [ { port = 81; } ];
    documentRoot = "/mnt/storage/mfscgi/";
    extraConfig = ''ScriptAlias /mfs.cgi /mnt/storage/mfscgi/mfs.cgi
Options ExecCGI
AddHandler cgi-script .cgi .pl'';
    # want ssl + a let's encrypt certificate? add `forceSSL = true;` right here
  };


  # Keeping this until Docker Swarm is enabled and all data is transfered.
  services.samba = {
    enable = true;
    package = pkgs.sambaFull;
    securityType = "user";
    openFirewall = true;
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "nix-es001";
        "netbios name" = "nix-es001";
        "security" = "user";
        #"use sendfile" = "yes";
        #"max protocol" = "smb2";
        # note: localhost is the ipv6 localhost ::1
        #"hosts allow" = "192.168. 127.0.0.1 localhost";
        #"hosts deny" = "0.0.0.0/0";
        "guest account" = "nobody";
        "map to guest" = "bad user";
      };
      "storage" = {
        "path" = "/mnt/storage";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0777";
        "directory mask" = "0777";
        "force user" = "root";
        "force group" = "root";
        "recycle:repository" = ".recycle";
        "recycle:keeptree" = "yes";
        "recycle:versions" = "yes";
        "guest account" = "user";
        "vfs objects" = "catia fruit streams_xattr";
        "fruit:nfs_aces" = "no";
      };
      "timemachine" = {
        "path" = "/mnt/storage/timemachine";
        "public" = "no";
        "create mask" = "0777";
        "directory mask" = "0777";
        "writeable" = "yes";
        "force user" = "root";
        "force group" = "root";
        "fruit:aapl" = "yes";
        "fruit:time machine" = "yes";
        "vfs objects" = "catia fruit streams_xattr";
      };
    };
  };
  
  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  services.tailscale.enable = true;
  virtualisation.docker.enable = true;
  virtualisation.docker.daemon.settings = {
    registry-mirrors =  [ "http://192.168.0.7:5000/" ];
  };
  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?

}
