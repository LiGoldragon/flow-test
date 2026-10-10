# Configure.Nexus whose MessageNexusBinary resolves to no file:
# Refused.NoSource.Path, carrying that path.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-configure-nexus-no-binary";
  target = "mind";
  script = ''
    expect("Configure.Nexus with no Message binary", meta(nexus_payload(binary="/nix/store/missing-message/bin/message-nexus")), "Refused.NoSource./nix/store/missing-message/bin/message-nexus")
  '';
}
