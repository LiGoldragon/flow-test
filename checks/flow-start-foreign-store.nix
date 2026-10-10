# A foreign file at StorePath (random bytes): the start is refused with one
# datom on standard output, the StartRefusal Store.{ Path «Reason» } naming
# that path, and a non-zero exit. The Reason's text is not given, so the
# reply is matched up to the path.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-start-foreign-store";
  target = "mind";
  script = ''
    store = "/home/alice/foreign.sema"
    rig(f"mkdir -p {RUNTIME}/foreign; head -c 4096 /dev/urandom > {store}")
    start_datom = f"Start.{{ {RUNTIME}/foreign/ordinary.sock {RUNTIME}/foreign/meta.sock {store} }}"
    status, out = machine.execute(as_alice(f"timeout 15 flow-nexus {shlex.quote(start_datom)} 2>/dev/null"), timeout=60)
    out = out.strip()
    judge("start on a foreign store", out, status, status not in (0, 124) and out.startswith(f"Store.{{ {store} "), f"«Store.{{ {store} …» and a non-zero exit")
    expect_true("one datom only", "\n" not in out, out)
  '';
}
