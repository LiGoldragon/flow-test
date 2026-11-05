# Refresh of an asleep metaflow: Refused.Asleep (a Wake launches it).
# Target: mind.
args@{ flake, ... }:
flake.lib.flowScenario args {
  name = "flow-refresh-asleep";
  target = "mind";
  script = ''
    configure()
    asleep("{ Mind nexus Secondary }", "mind")
    expect("Refresh asleep", flow("Refresh.{ Mind nexus Secondary }"), "Refused.Asleep")
  '';
}
