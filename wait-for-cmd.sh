#!/bin/bash -e

usage () {
    echo "usage: $0 [-erv] [-i interval] [-t timeout] cmd [args ..]" >&2
    exit 1
}

interval=5
timeout=60
verbose=0
redirerr=0
outputremaining=0
while getopts ":ei:rt:v" opt; do
    case "${opt}" in
        (e)
            redirerr=1
            ;;
        (i)
            interval=$OPTARG
            ;;
        (r)
            outputremaining=1
            ;;
        (t)
            timeout=$OPTARG
            ;;
        (v)
            verbose=1
            ;;
        (*)
            usage
            ;;
    esac
done
shift $((OPTIND-1))
cmd="$*"

if (( outputremaining && verbose )); then
    echo "output remaining and verbose are mutually exclusive!" >&2
    exit 1
fi

if [[ -z "$cmd" ]]; then
    usage
fi

now () {
    date +%s
}

base=$(now)
until=$(($base + $timeout))
remaining=$(($until - $(now)))

while true; do
    if (( $verbose == 1 )); then
        if bash -c "$cmd"; then
            echo "\"$cmd\" succeeded in $(($(now) - $base))s of ${timeout}s" >&2
            break
        fi
    elif (( $redirerr == 1 )); then
        if bash -c "$cmd" 1>&2; then
            echo "\"$cmd\" succeeded in $(($(now) - $base))s of ${timeout}s" >&2
            break
        fi
    else
        if bash -c "$cmd" > /dev/null 2> /dev/null; then
            echo "\"$cmd\" succeeded in $(($(now) - $base))s of ${timeout}s" >&2
            break
        fi
    fi

    remaining=$(($until - $(now)))
    if (( remaining <= 0 )); then
        echo "\"$cmd\" not ready, failing after $(($(now) - $base))s" >&2
        if (( $outputremaining )); then
            echo 0
        fi
        exit 1
    fi

    echo "\"$cmd\" not yet ready in $(($(now) - $base))s of ${timeout}s, retrying in ${interval}s" >&2
    sleep $interval
done

if (( $outputremaining )); then
    echo $remaining
fi
