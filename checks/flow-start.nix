# The Nexus's start command names its sockets: with the running Nexus
# stopped, flow-nexus 'Start.{ <ordinary> <meta> }' with two other paths
# binds both of them.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-start";
  target = "mind";
  script = ''
    rig("systemctl --user stop flow-nexus.service")
    ordinary = f"{RUNTIME}/started/ordinary.sock"
    meta_socket = f"{RUNTIME}/started/meta.sock"
    start_datom = f"Start.{{ {ordinary} {meta_socket} }}"
    rig(f"mkdir -p {RUNTIME}/started; systemd-run --user --unit=flow-started flow-nexus {shlex.quote(start_datom)}")
    status, _ = machine.execute(f"timeout 15 sh -c 'until test -S {ordinary} && test -S {meta_socket}; do sleep 0.2; done'")
    bound = machine.succeed(f"ls -la {RUNTIME}/started {RUNTIME}/flow 2>&1 || true")
    expect_true("both named sockets bound", status == 0, bound.replace("\n", " | "))
  '';
}
