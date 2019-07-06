#!/bin/bash -e

usage () {
    echo "usage: $0 [-r] [-i interval] [-t timeout] [-v] host port" >&2
    exit 1
}

interval=5
timeout=60
verbose=0
outputremaining=0
while getopts ":i:rt:v" opt; do
    case "${opt}" in
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
host=$1; shift || usage
port=$1; shift || usage

if [[ ${host%%:*} == ${host} ]]; then
    NAME="${host}:$port"
else
    set -f
    NAME="[${host}]:$port"
    set +f
fi

if (( outputremaining && verbose )); then
    echo "output remaining and verbose are mutually exclusive!" >&2
    exit 1
fi

now () {
    date +%s
}

base=$(now)
until=$(($base + $timeout))
remaining=$(($until - $(now)))

while true; do
    if (( $verbose )); then
        if (echo -n | nc -z "$host" "$port"); then
            echo "$NAME is ready in $(($(now) - $base)) of ${timeout}s" >&2
            break
        fi
    else
        if (echo -n | nc -z "$host" "$port") > /dev/null 2> /dev/null; then
            echo "$NAME is ready in $(($(now) - $base)) of ${timeout}s" >&2
            break
        fi
    fi

    remaining=$(($until - $(now)))
    if (( remaining <= 0 )); then
        echo "$NAME not ready, giving up after $(($(now) - $base))s" >&2
        if (( $outputremaining )); then
            echo 0
        fi
        exit 1
    fi

    echo "$NAME not yet ready in $(($(now) - $base))s of ${timeout}s, retrying in ${interval}s" >&2
    sleep $interval
done

if (( $outputremaining )); then
    echo $remaining
fi
