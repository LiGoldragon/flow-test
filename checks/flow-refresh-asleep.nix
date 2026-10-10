# Refresh of an asleep metaflow: Refused.Asleep (a Wake launches it).
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-refresh-asleep";
  target = "mind";
  script = ''
    configure()
    asleep("{ Mind nexus Secondary }", "mind")
    expect("Refresh asleep", flow("Refresh.{ Mind nexus Secondary }"), "Refused.Asleep")
  '';
}
