#!/bin/bash -e

# Parse command line arguments.
prune=false
push=false
cpu_shares=0
cpu_quota=-1
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --prune)
        prune=true
        shift
        ;;
        --push)
        push=true
        shift
        ;;
        --cpu-shares)
        cpu_shares="$2"
        shift
        shift
        ;;
        --cpu-quota)
        cpu_quota="$2"
        shift
        shift
        ;;
        *)
        echo "Unknown option $key"
        exit 1
        ;;
    esac
done

# Read the project version.
PROJECT_VERSION="$(cat ./tensorflow_cc/PROJECT_VERSION)"

for tag in ubuntu ubuntu-cuda archlinux archlinux-cuda; do
    docker build --cpu-shares="${cpu_shares}" --cpu-quota="${cpu_quota}" --pull -t floopcz/tensorflow_cc:${tag} -f Dockerfiles/${tag} .
    docker tag floopcz/tensorflow_cc:${tag} floopcz/tensorflow_cc:${tag}-"${PROJECT_VERSION}"
    if $push; then
        docker push floopcz/tensorflow_cc:${tag}
        docker push floopcz/tensorflow_cc:${tag}-"${PROJECT_VERSION}"
    fi
    if $prune; then
        docker rmi floopcz/tensorflow_cc:${tag}
        docker rmi floopcz/tensorflow_cc:${tag}-"${PROJECT_VERSION}"
        docker system prune -af
    fi
done
