# The frame of a pure scenario: one NixOS virtual machine with user `alice`
# (uid 1000, lingering) and two of her user services started with no
# arguments: the real Flow Nexus and a headless Herdr server whose panes are
# plain shells. The scenario supplies its name, its target, and its drive
# (Python, using the helpers of flow-scenario.py).
#
# target = "pass": the drive must meet every expectation.
# target = "mind": the drive is Mind's acceptance target, expected to miss
# against the pinned Flow. A miss is recorded as expected-failing and the
# check builds; a drive that meets every expectation fails the check, so the
# scenario is promoted to "pass" when Mind's build lands.
# Either way, a failure of the rig (the machine, the units, the sockets,
# Herdr, the drive's own Python) fails the check: broken.
{
  pkgs,
  flake,
  system,
}:
{
  name,
  target,
  script,
}:
assert builtins.elem target [
  "pass"
  "mind"
];
let
  flow = flake.lib.components.flow.forSystem system;
  herdr = flake.lib.components.herdr.forPkgs pkgs;
  runtime = "/run/user/1000";
  sourceRoot = "/etc/flow-test/source";
  indented = pkgs.lib.concatMapStringsSep "\n" (line: "    " + line) (
    pkgs.lib.splitString "\n" script
  );
in
pkgs.testers.runNixOSTest {
  inherit name;

  nodes.machine = _: {
    virtualisation.memorySize = 2048;

    users.users.alice = {
      isNormalUser = true;
      uid = 1000;
      linger = true;
    };

    environment.systemPackages = [
      flow.package
      herdr.package
      pkgs.b3sum
      pkgs.jq
    ];

    environment.etc."flow-test".source = ../fixtures/flow;

    systemd.user.services = {
      flow-nexus = {
        wantedBy = [ "default.target" ];
        unitConfig.ConditionUser = "alice";
        environment.RUST_LOG = "debug";
        serviceConfig.ExecStart = flow.nexus;
      };
      herdr = {
        wantedBy = [ "default.target" ];
        unitConfig.ConditionUser = "alice";
        path = [ "/run/current-system/sw" ];
        environment.SHELL = "${pkgs.bashInteractive}/bin/bash";
        serviceConfig.ExecStart = "${herdr.bin} server";
      };
    };
  };

  testScript = ''
    NAME = "${name}"
    TARGET = "${target}"
    RUNTIME = "${runtime}"
    SOURCE_ROOT = "${sourceRoot}"
    LAYERS = ${builtins.toJSON flow.layers}
    MODEL = "${flake.lib.cheapestModel.claude}"
    NEXUS_PAYLOAD = """${flow.nexusPayload runtime sourceRoot}"""
    ${builtins.readFile ./flow-scenario.py}

    def drive():
    ${indented}

    scenario(drive)
  '';
}
