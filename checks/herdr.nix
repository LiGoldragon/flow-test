# The rig the flow scenarios stand on: a headless Herdr server as a
# user service inside a NixOS virtual machine, with no terminal
# attached. A pane is opened, its shell pid read, a command typed into it,
# and its output read back; the pane carries HERDR_PANE_ID. Drives no Nexus.
{
  pkgs,
  flake,
  ...
}:
let
  herdr = flake.lib.components.herdr.forPkgs pkgs;
  testMachine = flake.lib.components.testMachine;
  inherit (testMachine) user;
in
pkgs.testers.runNixOSTest {
  name = "herdr";

  nodes.machine = _: {
    users.users.${user.name} = testMachine.userAccount;
    environment.systemPackages = [ herdr.package ];
    systemd.user.services.herdr = {
      inherit (testMachine.userService) wantedBy unitConfig;
      path = [ testMachine.systemPath ];
      environment.SHELL = "${pkgs.bashInteractive}/bin/bash";
      serviceConfig.ExecStart = "${herdr.bin} server";
    };
  };

  testScript = ''
    import json
    import shlex


    USER_NAME = "${user.name}"
    USER_UID = ${toString user.uid}
    USER_HOME = "${user.home}"
    RUNTIME = "${user.runtime}"


    def as_user(command):
        inner = f"export XDG_RUNTIME_DIR={RUNTIME}; {command}"
        return f"su -l {USER_NAME} -c " + shlex.quote(inner)


    def run_as_user(command):
        return machine.succeed(as_user(command)).strip()


    machine.wait_for_unit(f"user@{USER_UID}.service")
    machine.wait_for_unit("herdr.service", user=USER_NAME)
    machine.wait_until_succeeds(as_user("herdr workspace list"), timeout=60)
    created = json.loads(run_as_user(f"herdr workspace create --cwd {USER_HOME} --label rig --no-focus"))
    pane = created["result"]["root_pane"]["pane_id"]
    info = json.loads(run_as_user(f"herdr pane process-info --pane {pane}"))
    pid = info["result"]["process_info"]["shell_pid"]
    assert int(pid) > 1, f"no shell pid for {pane}: {info}"
    run_as_user(f"herdr pane run {pane} " + shlex.quote("echo rig-$HERDR_PANE_ID-$$"))
    run_as_user(f"herdr pane wait-output {pane} --match {shlex.quote(f'rig-{pane}-{pid}')} --timeout 15000")
  '';
}
