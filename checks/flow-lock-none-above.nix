# Lock.{ Sender Up } with Sender { Mind nexus Primary }, the top of its
# aspect: Refused.NoneAbove.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-lock-none-above";
  target = "mind";
  script = ''
    configure()
    awake("{ Mind nexus Primary }", "primary")
    expect("Lock Up from the Primary", flow(lock_datom("{ Mind nexus Primary }", "Up")), "Refused.NoneAbove")
  '';
}
