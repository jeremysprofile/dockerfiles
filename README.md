There is no automation.
```bash
dcon jeremydr2/kafka:latest
dbuild
dpush
```

Use it:
```bash
ktest jeremydr/kafka
export KAFKA_BROKERS=""
kafkaversion
```

Using:
```bash
dockerstart() {
    [[ "$__os" == 'mac' ]] || { echo "This only runs on macOS." >&2; return 2; }
    echo "-- Starting Docker.app, if necessary..."

    open -g -a Docker.app || return

    # Wait for the server to start up, if applicable.  
    i=0
    while ! docker system info &>/dev/null; do
      (( i++ == 0 )) && printf %s '-- Waiting for Docker to finish starting up...' || printf '.'
      sleep 1
    done
    (( i )) && printf '\n'

    echo "-- Docker is ready."
}

if [[ -z "$dimage" ]]; then
    export dimage='test'
fi
if [[ -z "$dtag" ]]; then
    export dtag='latest'
fi
if [[ -z "$dproj" ]]; then
    export dproj='jeremydr2'
fi

dcon() {
  if [[ $# -gt 0 ]]; then
    local input="$1"
    dtag=${input##*:}
    input=${input%:*}
    dimage=${input##*/}
    if [[ "$input" =~ ^"$__hub" ]]; then
      input=${input##$__hub/}
    fi
    dproj=${input%/*}
  else
    read -e -i "$dimage" -p "Image name: " dimage
    read -e -i "$dtag" -p "Tag name: " dtag
    read -e -i "$dproj" -p "Project name (in $__hub): " dproj
  fi
  echo "Set to build/run/push $__hub/$dproj/$dimage:$dtag"
}


alias dbuild='echo "building $dimage:$dtag"; docker build . -t $dimage:$dtag --platform linux/x86_64'

drun() {  # runs the docker image in stdout
  if [[ $# -gt 0 ]]; then
    echo "running $@"
    docker run -it --rm --name test "$@" --platform linux/x86_64
  else
    echo "running $dimage:$dtag"
    docker run -it --rm --name test $dimage:$dtag
  fi
}

alias dpush='echo "pushing $__hub/$dproj/$dimage:$dtag"; \
    docker tag $dimage:$dtag $__hub/$dproj/$dimage:$dtag; \
    docker push $__hub/$dproj/$dimage:$dtag'
alias dpull='echo "pulling $__hub/$dproj/$dimage:$dtag or $dimage:$dtag"; \
    { docker pull $__hub/$dproj/$dimage:$dtag && \
      docker tag $__hub/$dproj/$dimage:$dtag $dimage:$dtag; } || docker pull $dimage:$dtag'
```
