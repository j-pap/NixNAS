# NixNAS

This flake repository serves multiple purposes:

* Provide the UGreen LED bin & kernel module that I've packaged for Nix.
* My configuration files for servers dedicated to running a NAS.

Setup instructions are available below.

---

## UGreen LED Packages

### 01. Add flake input

Inside your flake.nix file, add the following to your inputs:

```nix
inputs.nixnas.url = "github:j-pap/NixNAS";
```

### 02. Set overlay

Add the input's overlay to your system:

```nix
nixpkgs.overlays = [ inputs.nixnas.overlays.default ];
```

### 03. Add i2c to extraGroups

```nix
users.users.<name>.extraGroups = [
  "i2c"
];
```

### 04. Enable module & set options

Besides the module enable, disk serials, and the network interface, all the values
below are the defaults. Feel free to set them as you please.

```nix
config.ugreen.leds = {
  enable = true;

  disk = {
    serials = [
      "serial1"
      "serial2"
      ...
    ];
    brightness = 255;
    colors = {
      health = "255 255 255"; # white
      unavail = "255 0 0"; # red
      standy = "0 0 255"; # blue
      smart = {
        enable = true;
        fail = "255 0 0"; # red
      };
      zpool = {
        enable = false;
        fail = "255 0 0" # red
      };
    };
  };

  network = {
    interface = "enp1s0";
    brightness = 255;
    colors = {
      normal = "255 165 0"; # orange
      link = {
        enable = false;
        m100 = "0 255 0"; # green
        g1000 = "0 0 255"; # blue
        g2500 = "255 255 0"; # yellow
        g10000 = "255 255 255"; # white
      };
      gateway = {
        enable = false;
        unreachable = "255 0 0"; # red
      };
    };
  };

  power = {
    brightness = 255;
    color = "255 255 255"; # white
  };
};
```

#### Credits

[miskcoo](https://github.com/miskcoo) for creating the initial [LED Controller](https://github.com/miskcoo/ugreen_leds_controller).

---

## NixNAS Installation

All servers share a common configuration via hosts/default.nix. Any
server-specific configurations are then set by their respective host directory.

### Quick Deployment

```
nix run github:nix-community/disko -- --mode disko --flake github:j-pap/NixNAS#<server>
mkdir -p /mnt/etc/nixos
git clone https://github.com/j-pap/NixNAS.git /mnt/etc/nixos
nixos-install --no-root-passwd --flake .#<server>
```
