# A short lease: Configure.Nexus with Lease 3 seconds; a Lock's Until is 3
# seconds away, and once that time has passed (real time, the clock
# untouched) a Deliver under it is Refused.Lapsed and a new Lock is
# granted.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-lock-lease";
  target = "mind";
  script = ''
    expect("Configure.Nexus with Lease 3", meta(nexus_payload(3)), "Configured")
    for layer in LAYERS:
        expect(f"Configure.Model {layer}", meta(f"Configure.Model.{{ {layer} {MODEL} }}"), "Configured")
    awake(PSYCHE, "psyche")
    pane, _, _ = awake("{ Mind nexus Secondary }", "mind")
    now = int(machine.succeed("date +%s").strip())
    held, until = lock(PSYCHE, "{ Mind nexus Secondary }")
    expect_true("Until is the lease away", 3 <= until - now <= 5, f"Until {until}, now {now}")
    machine.wait_until_succeeds(f"test $(date +%s) -gt {until}", timeout=30)
    expect_message("Deliver after the lease", deliver(held, "Order.«ftLease»"), "Refused.Lapsed")
    pane_lacks("recipient pane", pane, "ftLease")
    lock(PSYCHE, "{ Mind nexus Secondary }", "Lock after the lapse")
  '';
}
