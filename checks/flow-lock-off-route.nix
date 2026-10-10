# Lock from { Field ghost Tertiary } to { Psyche core Primary }: another
# aspect, another layer, another topic, off the vision-aspects routes:
# Refused.OffRoute at the Lock.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-lock-off-route";
  target = "mind";
  script = ''
    configure()
    awake("{ Field ghost Tertiary }", "field")
    awake("{ Psyche core Primary }", "psyche")
    expect("Lock off route", flow(lock_datom("{ Field ghost Tertiary }", "{ Psyche core Primary }")), "Refused.OffRoute")
  '';
}
