# The Nexus's start command names its sockets and its store: with the
# running Nexus stopped, flow-nexus 'Start.{ <ordinary> <meta> <store> }'
# with three other paths binds both sockets and opens its store at the
# third path.
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
    store = "/home/alice/started-state/flow.sema"
    start_datom = f"Start.{{ {ordinary} {meta_socket} {store} }}"
    rig(f"mkdir -p {RUNTIME}/started /home/alice/started-state; systemd-run --user --unit=flow-started flow-nexus {shlex.quote(start_datom)}")
    status, _ = machine.execute(f"timeout 15 sh -c 'until test -S {ordinary} && test -S {meta_socket}; do sleep 0.2; done'")
    bound = machine.succeed(f"ls -la {RUNTIME}/started {RUNTIME}/flow 2>&1 || true")
    expect_true("both named sockets bound", status == 0, bound.replace("\n", " | "))
    status, _ = machine.execute(f"timeout 15 sh -c 'until test -e {store}; do sleep 0.2; done'")
    expect_true("the store at the named path", status == 0, machine.succeed("ls -la /home/alice/started-state 2>&1 || true").replace("\n", " | "))
  '';
}
