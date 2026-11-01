#!/usr/bin/env zsh

set -eu

flake_ref=${0:A:h:h}

activation_of() {
  nix eval --impure --raw "$flake_ref#darwinConfigurations.$1.config.system.activationScripts.homebrew.text"
}

# Line number of the first (or, with `tail`, the last) line that matches a regex.
line_of() {
  local match
  match=$(print -r -- "$activation" | rg -n -- "$1" | ${2:-head} -1)
  print -- ${match%%:*}
}

# 1. Every host repairs Docker's privileged helpers: they need root, which only
#    activation has.  Only mac-mini-m1 Declares docker-desktop, so only its
#    bundle upgrades Docker, and the other hosts never stop it.
for config_name in default macbook-pro-2015 mac-mini-m4 mac-mini-m1; do
  activation=$(activation_of $config_name)

  if [[ -z $(line_of 'Contents/MacOS/install" config --user') ]]; then
    print -u2 -- "$config_name never installs Docker's privileged helpers"
    exit 1
  fi
  print -- "$config_name reinstalls Docker's privileged helpers"

  [[ $config_name == mac-mini-m1 ]] && continue
  if [[ -n $(line_of 'desktop stop') || -n $(line_of '^\s*trap ') ]]; then
    print -u2 -- "$config_name stops a Docker Desktop that its bundle does not Declare"
    exit 1
  fi
  print -- "$config_name leaves an undeclared Docker Desktop alone"
done

# 2. On mac-mini-m1, Docker stops only when its cask has an upgrade waiting,
#    before `brew bundle`.  A trap brings it back if the bundle fails.  After the
#    helpers are back, the trap is cleared and Docker starts again.
activation=$(activation_of mac-mini-m1)
outdated_line=$(line_of 'outdated --cask --greedy --quiet docker-desktop')
stop_line=$(line_of 'desktop stop')
trap_line=$(line_of "^\\s*trap '.*startStoppedDocker' EXIT")
bundle_line=$(line_of 'brew bundle --file=')
install_line=$(line_of '^\s*"\$dockerApp/Contents/MacOS/install" config')
untrap_line=$(line_of '^\s*trap - EXIT')
start_line=$(line_of '^\s*startStoppedDocker$' tail)

for name in outdated_line stop_line trap_line bundle_line install_line untrap_line start_line; do
  if [[ -z ${(P)name} ]]; then
    print -u2 -- "mac-mini-m1 activation has no ${name%_line} step"
    exit 1
  fi
done

if ! (( outdated_line < stop_line && stop_line < trap_line && trap_line < bundle_line &&
  bundle_line < install_line && install_line < untrap_line && untrap_line < start_line )); then
  print -u2 -- 'mac-mini-m1 does not stop Docker around its cask upgrade in the right order'
  exit 1
fi
print -- 'mac-mini-m1 stops Docker for a waiting upgrade, before the bundle, and starts it after the helpers'

# 3. Run that activation text, with every outside command swapped for a stub
#    that logs its call.  Only the Docker steps matter here: the Emacs sync sees
#    no keg and does nothing.
work=$(mktemp -d)
trap 'rm -rf $work' EXIT
stub=$work/stub
mkdir -p $stub/bin $stub/hb/bin $stub/Docker.app/Contents/{MacOS,Resources/bin}

write_stub() {
  print -r -- "#!/bin/sh"$'\n'"$2" >$1
  chmod +x $1
}
write_stub $stub/bin/launchctl 'shift 2; exec "$@"'
write_stub $stub/bin/id 'echo 501'
write_stub $stub/bin/pgrep '[ -n "$DOCKER_RUNNING" ]'
write_stub $stub/bin/sudo 'while [ "${1#-}" != "$1" ]; do shift; done; exec "$@"'
write_stub $stub/hb/bin/brew 'echo "brew $1" >>"$LOG"
case $1 in
  outdated) [ -n "$UPGRADE" ] && echo docker-desktop; exit 0 ;;
  bundle) [ -z "$BUNDLE_FAILS" ]; exit $? ;;
esac'
write_stub $stub/Docker.app/Contents/Resources/bin/docker 'echo "docker $2" >>"$LOG"
[ "$2" != stop ] || [ -z "$STOP_FAILS" ]'
write_stub $stub/Docker.app/Contents/MacOS/install 'echo "install $1" >>"$LOG"'

script=$work/activation.sh
{
  print -- 'set -e'
  print -r -- "$activation" |
    sed -e "s#/bin/launchctl#$stub/bin/launchctl#g" -e "s#/usr/bin/id#$stub/bin/id#g" \
      -e "s#/usr/bin/pgrep#$stub/bin/pgrep#g" -e "s#/Applications/Docker.app#$stub/Docker.app#g" \
      -e "s#/opt/homebrew#$stub/hb#g"
} >$script

# Run one case: env assignments, then the expected exit status and log.
run_case() {
  local name=$1 want_status=$2 want_log=$3 got_status=0
  shift 3
  : >$work/log
  env PATH=$stub/bin:$PATH LOG=$work/log "$@" bash $script >/dev/null 2>&1 || got_status=$?
  local got_log=${(j:, :)${(f)"$(<$work/log)"}}
  if [[ $got_status != $want_status || $got_log != $want_log ]]; then
    print -u2 -- "$name: want status $want_status and [$want_log], got status $got_status and [$got_log]"
    exit 1
  fi
  print -- "$name"
}

run_case 'a waiting upgrade stops Docker, then starts it after the helpers' 0 \
  'brew update, brew outdated, docker stop, brew bundle, install config, docker start' \
  DOCKER_RUNNING=1 UPGRADE=1
run_case 'a failed bundle after the stop still repairs the helpers and starts Docker' 1 \
  'brew update, brew outdated, docker stop, brew bundle, install config, docker start' \
  DOCKER_RUNNING=1 UPGRADE=1 BUNDLE_FAILS=1
run_case 'no waiting upgrade leaves Docker running' 0 \
  'brew update, brew outdated, brew bundle, install config' \
  DOCKER_RUNNING=1
run_case 'a stopped Docker is not checked or started' 0 \
  'brew bundle, install config' \
  DOCKER_RUNNING=
run_case 'a Docker that will not stop is not started again' 0 \
  'brew update, brew outdated, docker stop, docker stop, brew bundle, install config' \
  DOCKER_RUNNING=1 UPGRADE=1 STOP_FAILS=1
