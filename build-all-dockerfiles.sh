#!/bin/bash -e

# Parse command line arguments.
prune=false
push=false
for key in "$@"; do
    case $key in
        --prune)
        prune=true
        ;;
        --push)
        push=true
        ;;
    esac
done

# Read the project version.
PROJECT_VERSION="$(cat ./tensorflow_cc/PROJECT_VERSION)"

for tag in ubuntu ubuntu-cuda archlinux archlinux-cuda; do
    docker build --pull -t floopcz/tensorflow_cc:${tag} -f Dockerfiles/${tag} .
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
