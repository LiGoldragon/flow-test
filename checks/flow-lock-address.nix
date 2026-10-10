# Lock.{ Sender Recipient } with an Address, from { Psyche nexus
# Secondary } to the awake { Mind nexus Secondary }: Locked.Lock, the lock
# carrying the Address and an Until in the future.
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
    awake(PSYCHE, "psyche")
    awake("{ Mind nexus Secondary }", "mind")
    now = int(machine.succeed("date +%s").strip())
    held, until = lock(PSYCHE, "{ Mind nexus Secondary }")
    expect_true("the lock is { Sender Address Until }", held == f"{{ {PSYCHE} {{ Mind nexus Secondary }} {until} }}", held)
    expect_true("Until is after now", until > now, f"Until {until}, now {now}")
  '';
}
