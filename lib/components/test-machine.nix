# The user and service frame shared by every NixOS virtual machine test.
rec {
  user = rec {
    name = "alice";
    uid = 1000;
    home = "/home/${name}";
    runtime = "/run/user/${toString uid}";
  };

  userAccount = {
    isNormalUser = true;
    inherit (user) uid;
    linger = true;
  };

  userService = {
    wantedBy = [ "default.target" ];
    unitConfig.ConditionUser = user.name;
  };

  systemPath = "/run/current-system/sw";
}
