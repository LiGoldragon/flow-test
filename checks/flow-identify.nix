# Identify.Process of a bound pane's shell answers its metaflow's address;
# so does a process descending from that shell (Flow walks the ancestors).
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-identify";
  target = "mind";
  script = ''
    configure()
    pane, pid, _ = awake("{ Mind nexus Secondary }", "mind")
    expect("Identify the shell", flow(f"Identify.{process(pid)}"), "Identified.{ Mind nexus Secondary }")
    in_pane(pane, "sleep 600 & echo $! > /tmp/descendant")
    child = int(machine.succeed("cat /tmp/descendant").strip())
    expect("Identify a descendant", flow(f"Identify.{process(child)}"), "Identified.{ Mind nexus Secondary }")
  '';
}
