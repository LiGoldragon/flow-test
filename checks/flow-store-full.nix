# A store failure is refused Refused.Store.String, carrying the store's
# error text. The failure is provoked by filling the disk the store lives
# on (as root, past the reserved blocks), then asking for a Bind, which
# writes a Flow record and a metaflow.
# Target: mind.
args@{ flake, ... }:
flake.lib.flowScenario args {
  name = "flow-store-full";
  target = "mind";
  script = ''
    configure()
    _, pid = open_pane("mind")
    machine.succeed(f"fallocate -l $(df --output=avail -B1 {USER_HOME} | tail -1) /fill || true")
    machine.succeed("dd if=/dev/zero of=/fill-rest bs=1M 2>/dev/null || true")
    expect_prefix("Bind on a full disk", flow(f"Bind.{{ {{ Mind nexus Secondary }} {process(pid)} }}"), "Refused.Store.")
  '';
}
