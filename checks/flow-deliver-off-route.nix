# Deliver from { Field ghost Tertiary } to { Psyche core Primary }: another
# aspect, another layer, another topic, off the vision-aspects routes:
# Refused.OffRoute, and the recipient's pane never shows it.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-deliver-off-route";
  target = "mind";
  script = ''
    configure()
    awake("{ Field ghost Tertiary }", "field")
    pane, _, _ = awake("{ Psyche core Primary }", "psyche")
    held, _ = lock("{ Psyche core Primary }")
    expect("Deliver", flow(f"Deliver.{{ {held} {{ Field ghost Tertiary }} Order.«ftOffRoute» }}"), "Refused.OffRoute")
    pane_lacks("recipient pane", pane, "ftOffRoute")
  '';
}
