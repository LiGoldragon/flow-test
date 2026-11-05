# The frame of a pure scenario: one NixOS virtual machine with the shared test
# user and two user services started with no arguments: the real Flow Nexus
# and a headless Herdr server whose panes are
# plain shells. User identity and paths come from components.testMachine. The
# scenario supplies its name, its target, and its drive
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
  ...
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
  testMachine = flake.lib.components.testMachine;
  inherit (testMachine) user;
  messageHelper = flow.messageHelper pkgs;
  sourceRoot = "/etc/flow-test/source";
  indented = pkgs.lib.concatMapStringsSep "\n" (line: "    " + line) (
    pkgs.lib.splitString "\n" script
  );
in
pkgs.testers.runNixOSTest {
  inherit name;

  nodes.machine = _: {
    virtualisation.memorySize = 2048;

    users.users.${user.name} = testMachine.userAccount;

    environment.systemPackages = [
      flow.package
      messageHelper
      herdr.package
      pkgs.b3sum
      pkgs.jq
    ];

    environment.etc."flow-test".source = ../fixtures/flow;

    systemd.user.services = {
      flow-nexus = {
        inherit (testMachine.userService) wantedBy unitConfig;
        environment.RUST_LOG = "debug";
        serviceConfig.ExecStart = "${flow.nexus} \"${flow.startArgument user.runtime user.home}\"";
      };
      herdr = {
        inherit (testMachine.userService) wantedBy unitConfig;
        path = [ testMachine.systemPath ];
        environment.SHELL = "${pkgs.bashInteractive}/bin/bash";
        serviceConfig.ExecStart = "${herdr.bin} server";
      };
    };
  };

  testScript = ''
    NAME = "${name}"
    TARGET = "${target}"
    USER_NAME = "${user.name}"
    USER_UID = ${toString user.uid}
    USER_HOME = "${user.home}"
    RUNTIME = "${user.runtime}"
    SOURCE_ROOT = "${sourceRoot}"
    LAYERS = ${builtins.toJSON flow.layers}
    MODEL = "${flake.lib.cheapestModel.claude}"
    NEXUS_TEMPLATE = """${
      flow.nexusPayload {
        inherit sourceRoot;
        inherit (user) home runtime;
        messageNexusBinary = "MESSAGE_BINARY";
        lease = "LEASE";
      }
    }"""
    MESSAGE_HELPER = "${messageHelper}/bin/message-helper"
    ${builtins.readFile ./flow-scenario.py}

    def drive():
    ${indented}

    scenario(drive)
  '';
}
