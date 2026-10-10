# Wake of an Asleep metaflow with a Notice, then a Result: neither wakes
# it (the waking rule), each answers Queued, Current stays Asleep, and the
# metaflow's Queue holds both, oldest first, as Metaflows lists it.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-wake-queued";
  target = "mind";
  script = ''
    configure()
    asleep("{ Mind wake Secondary }", "wake")
    expect("Wake with a Notice", flow("Wake.{ { Mind wake Secondary } Notice.ftWakeNotice }"), "Queued")
    expect("Wake with a Result", flow("Wake.{ { Mind wake Secondary } Result.ftWakeResult }"), "Queued")
    expect("Current after", flow("Current.{ Mind wake Secondary }"), "Current.Asleep")
    listed = expect_prefix("Metaflows", flow("Metaflows"), "Listed.")
    expect_true("the Queue holds the Notice then the Result", re.search(r"\[ Notice\.ftWakeNotice Result\.ftWakeResult \]", listed) is not None, listed)
  '';
}
