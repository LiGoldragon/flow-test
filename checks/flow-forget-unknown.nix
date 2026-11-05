# Forget of a key the registry does not hold:
# Refused.Unknown.{ Vision ghost } (the meta socket's one Unknown, carrying
# the Key bare).
# Target: mind.
args@{ flake, ... }:
flake.lib.flowScenario args {
  name = "flow-forget-unknown";
  target = "mind";
  script = ''
    configure()
    expect("Forget", meta("Forget.{ Vision ghost }"), "Refused.Unknown.{ Vision ghost }")
  '';
}
