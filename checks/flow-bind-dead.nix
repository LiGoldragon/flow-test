# Bind of a process that has exited, and of a live pid with another start
# time (a reused pid): each Refused.Unidentified.Process.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-bind-dead";
  target = "mind";
  script = ''
    configure()
    pane, pid = open_pane("mind")
    in_pane(pane, "sleep 600 & echo $! > /tmp/dead")
    dead = int(machine.succeed("cat /tmp/dead").strip())
    gone = process(dead)
    machine.succeed(f"kill {dead}; while kill -0 {dead} 2>/dev/null; do sleep 0.1; done")
    expect("Bind a dead process", meta(f"Bind.{{ {{ Mind nexus Secondary }} {gone} }}"), f"Refused.Unidentified.{gone}")
    reused = process(pid, started_of(pid) + 1)
    expect("Bind a reused pid", meta(f"Bind.{{ {{ Mind nexus Secondary }} {reused} }}"), f"Refused.Unidentified.{reused}")
  '';
}
