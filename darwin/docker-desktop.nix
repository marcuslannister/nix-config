# darwin/docker-desktop.nix
#
# Keep Docker Desktop working across `darwin-rebuild switch` on a headless Mac.
#
# Docker Desktop keeps two privileged helpers, com.docker.vmnetd and
# com.docker.socket, in /Library/LaunchDaemons.  Only root can install them.  A
# cask upgrade replaces Docker.app, and the cask's uninstall step deletes both
# helpers.  Docker then asks for an admin password in a dialog.  Nobody answers
# that dialog on a headless Mac.  Activation runs as root, so it does the
# install itself.
#
# 1. `install config` runs on every switch, after `brew bundle`.  It is the
#    step that Docker runs itself.  It is idempotent, so it also repairs a stale
#    pair.  A Mac with no Docker.app skips it.
# 2. A running Docker must not see the helpers go.  On 2026-10-29 the backend
#    outlived the cask's quit and opened the dialog.  It kept waiting after
#    step 1 had put the helpers back, and Docker stayed down for 10 hours.  So
#    when Docker runs and its cask has an upgrade waiting, activation stops
#    Docker before `brew bundle` and starts it again after step 1.  Only a host
#    whose bundle Declares the cask does this.  Its bundle is the only one that
#    upgrades Docker; a leftover Docker.app on another host stays as it is.
#
# No Docker step aborts the switch: activation runs under `set -e`, so each
# failure only warns.
{ config, lib, username, ... }:

let
  brew = "${config.homebrew.prefix}/bin/brew";
  dockerDeclared = lib.any (cask: cask.name == "docker-desktop") config.homebrew.casks;
in
{
  system.activationScripts.homebrew.text = lib.mkMerge [
    (lib.mkBefore (''
      dockerApp=/Applications/Docker.app
    '' + lib.optionalString dockerDeclared ''
      asUser() { /bin/launchctl asuser "$(/usr/bin/id -u ${username})" sudo --user=${username} --set-home "$@"; }
      dockerCli=$dockerApp/Contents/Resources/bin/docker
      dockerStopped=
      startStoppedDocker() {
        [ -n "$dockerStopped" ] || return 0
        dockerStopped=
        asUser "$dockerCli" desktop start --detach >/dev/null 2>&1 ||
          echo >&2 "warning: could not start Docker Desktop after its upgrade -- start it by hand"
      }

      if [ -x "$dockerCli" ] && [ -x "${brew}" ] &&
        /usr/bin/pgrep -f "$dockerApp/Contents/MacOS/com.docker.backend" >/dev/null; then
        # Update first.  Otherwise `outdated` can miss a release that the
        # bundle's own update finds.
        if ! asUser "${brew}" update --quiet >/dev/null 2>&1; then
          echo >&2 "warning: could not update Homebrew -- not checking for a Docker Desktop upgrade"
        elif [ -n "$(asUser "${brew}" outdated --cask --greedy --quiet docker-desktop 2>/dev/null)" ]; then
          echo >&2 "Stopping Docker Desktop before its cask upgrade..."
          # Force the stop only when a normal stop times out.  A Docker that
          # keeps running sees its helpers go.
          if asUser "$dockerCli" desktop stop --timeout 120 >/dev/null 2>&1 ||
            asUser "$dockerCli" desktop stop --force --timeout 60 >/dev/null 2>&1; then
            dockerStopped=1
            # A failed `brew bundle` ends activation here.  Docker must come
            # back all the same, with its helpers in place.
            trap '"$dockerApp/Contents/MacOS/install" config --user ${username} >/dev/null 2>&1; startStoppedDocker' EXIT
          else
            echo >&2 "warning: could not stop Docker Desktop -- its upgrade may leave it waiting for an admin password"
          fi
        fi
      fi
    ''))

    (lib.mkAfter (''
      if [ -x "$dockerApp/Contents/MacOS/install" ]; then
        "$dockerApp/Contents/MacOS/install" config --user ${username} >/dev/null ||
          echo >&2 "warning: could not install Docker's privileged helpers -- Docker Desktop will ask for an admin password on its next start"
      fi
    '' + lib.optionalString dockerDeclared ''

      # dockerStopped, the trap and startStoppedDocker come from the step
      # before `brew bundle`.
      trap - EXIT
      startStoppedDocker
    ''))
  ];
}
