# Lock.Recipient with an Address on an awake metaflow:
# Locked.{ { Mind nexus Secondary } Until }, Until in the future.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-lock-address";
  target = "mind";
  script = ''
    configure()
    awake("{ Mind nexus Secondary }", "mind")
    now = int(machine.succeed("date +%s").strip())
    reply = expect_prefix("Lock", flow("Lock.Address.{ Mind nexus Secondary }"), "Locked.{ { Mind nexus Secondary } ")
    _, until = lock_of(reply)
    expect_true("Until is after now", until > now, f"Until {until}, now {now}")
  '';
}
