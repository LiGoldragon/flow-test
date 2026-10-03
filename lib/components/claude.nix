# Claude Code: the harness a semi-sandbox drives, from the pinned nixpkgs. It
# is unfree, so this component imports nixpkgs with claude-code alone
# allowed. `binary` is nixpkgs' own wrapper, which sets environment only and
# adds no flag: never the living's installed `claude`, which prepends
# --dangerously-skip-permissions to every call.
{ inputs }:
{
  name = "claude";

  forSystem = system: rec {
    package =
      (import inputs.nixpkgs {
        inherit system;
        config.allowUnfreePredicate = drv: (drv.pname or "") == "claude-code";
      }).claude-code;

    binary = "${package}/bin/claude";

    # The only login file a sandbox copies, relative to the living's HOME.
    credentials = ".claude/.credentials.json";
  };
}
