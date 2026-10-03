# The frame every pure Flow scenario shares: a fresh root inside the build
# sandbox with its own HOME and XDG_RUNTIME_DIR (Flow's two anchors); the
# `expect` and `expectFailure` assertions; and an exit trap that kills the
# Nexus, because a backgrounded Nexus left running holds the build log open
# and turns a failing assertion into a hang. The scenario supplies only its
# drive.
{ pkgs, name }:
drive:
pkgs.runCommand name
  {
    nativeBuildInputs = [
      pkgs.coreutils
    ];
  }
  ''
    root="$(mktemp -d)"
    export HOME="$root/home"
    export XDG_RUNTIME_DIR="$root/runtime"
    mkdir -p "$HOME"

    # expect <label> <exit code> <reply> <command...>: the command's whole
    # stdout must equal <reply> and its exit code <exit code>.
    expect() {
      label="$1" wantCode="$2" want="$3"
      shift 3
      set +e
      got="$(timeout 10 "$@")"
      code=$?
      set -e
      echo "$label: $got (exit $code)"
      if [ "$got" != "$want" ] || [ "$code" != "$wantCode" ]; then
        echo "$label: expected $want (exit $wantCode)" >&2
        exit 1
      fi
    }

    # expectFailure <label> <exit code> <failure> <command...>: a client
    # failure is printed on stderr, so stdout must be empty, the whole stderr
    # must equal <failure>, and the exit code <exit code>.
    expectFailure() {
      label="$1" wantCode="$2" want="$3"
      shift 3
      set +e
      got="$(timeout 10 "$@" 2>"$root/stderr")"
      code=$?
      set -e
      gotError="$(cat "$root/stderr")"
      echo "$label: stdout «$got» stderr «$gotError» (exit $code)"
      if [ -n "$got" ] || [ "$gotError" != "$want" ] || [ "$code" != "$wantCode" ]; then
        echo "$label: expected stderr $want (exit $wantCode)" >&2
        exit 1
      fi
    }

    trap 'kill "''${flowNexusPid:-}" 2>/dev/null || true' EXIT

    ${drive}

    echo "${name}: torn down"
    rm -rf "$root"
    touch $out
  ''
