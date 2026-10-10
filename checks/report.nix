# The report: every scenario's outcome, one line each, grouped as passing,
# expected-failing (a Mind target, with the expectation it missed), and the
# steps each ran. Building it builds every scenario; a broken or
# unexpectedly passing scenario fails its own check and therefore this one.
# Read it with `nix build .#checks.<system>.report && cat result`.
{
  pkgs,
  flake,
  inputs,
  system,
  ...
}:
let
  scenarios = pkgs.lib.filterAttrs (name: _: pkgs.lib.hasPrefix "flow-" name) flake.checks.${system};
  outcomes = pkgs.lib.concatMapStringsSep " " (check: "${check}/outcome") (
    builtins.attrValues scenarios
  );
in
pkgs.runCommand "report" { } ''
  {
    echo "Written to Flow's design (flows/f5a6e9/reports/flow-buildable-design.md): Primary ${flake.lib.design}."
    echo "Flow pinned at ${inputs.flow.rev}."
    echo
    echo "passing:"
    grep -h ': passing$' ${outcomes} | sed 's/^/  /' || true
    echo
    echo "expected-failing (Mind targets):"
    grep -h ': expected-failing (Mind target): ' ${outcomes} | sed 's/^/  /' || true
    echo
    echo "steps:"
    cat ${outcomes}
  } > $out
  cat $out
''
