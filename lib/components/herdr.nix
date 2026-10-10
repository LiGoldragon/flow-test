# Herdr: the terminal multiplexer Flow opens panes in. A scenario runs
# `herdr server` headless (no terminal attached); its panes are the plain
# shells a scenario binds to metaflows.
{
  forPkgs = pkgs: rec {
    package = pkgs.herdr;
    bin = "${package}/bin/herdr";
  };
}
