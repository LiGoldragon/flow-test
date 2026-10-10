# Identify.Process of a shell in no metaflow, and of a bound shell's pid
# with another start time (a reused pid): each Refused.Unidentified.Process,
# carrying the process asked about.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-identify-unidentified";
  target = "mind";
  script = ''
    configure()
    _, stranger = open_pane("stranger")
    asked = process(stranger)
    expect("Identify an unbound shell", flow(f"Identify.{asked}"), f"Refused.Unidentified.{asked}")
    _, pid, _ = awake("{ Mind nexus Secondary }", "mind")
    reused = process(pid, started_of(pid) + 1)
    expect("Identify a reused pid", flow(f"Identify.{reused}"), f"Refused.Unidentified.{reused}")
  '';
}
