#! /usr/bin/env bash

# change this
CONTAINER_IMAGE=gitea

function print_usage() {
    echo "usage: $0 [(-b |--build=)(local|quay)] [(-p |--project=)QUAY_PROJECT] [(-t |--tag=)CONTAINER_TAG] [-l|--latest] [-d|--date] [-- BUILD_ARGS]" | fold -s
}

# parse args
while [ $# -gt 0 ]; do
    case "$1" in
        -b|--build=*)
            if [ "$1" = '-b' ]; then
                shift
                BUILD="$1"
            else
                BUILD=$(echo "$1" | cut -d= -f2-)
            fi
            ;;
        -p|--project=*)
            if [ "$1" = '-p' ]; then
                shift
                QUAY_PROJECT="$1"
            else
                QUAY_PROJECT=$(echo "$1" | cut -d= -f2-)
            fi
            ;;
        -t|--tag=*)
            if [ "$1" = '-t' ]; then
                shift
                CONTAINER_TAG="$1"
            else
                CONTAINER_TAG=$(echo "$1" | cut -d= -f2-)
            fi
            ;;
        -l|--latest)
            TAG_ALSO_LATEST=true
            ;;
        -d|--date)
            BUILD_DATE=$(date +'%Y-%m-%d')
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Invalid option: $1" >&2
            print_usage >&2
            exit 127
            ;;
    esac
    shift
done

# some defaults
if [ -f .quay_creds -a -z "$BUILD" ]; then
    BUILD=quay
    . .quay_creds
elif [ -z "$BUILD" ]; then
    BUILD=local
fi
if [ -z "$QUAY_PROJECT" ]; then
    QUAY_PROJECT=redhatgov
fi
if [ -z "$CONTAINER_TAG" ]; then
    CONTAINER_TAG=latest
fi

# docker/podman problems
if ! which docker &>/dev/null; then
    if which podman &>/dev/null; then
        function docker() { podman "${@}" ; }
    else
        echo "No docker|podman installed :(" >&2
        exit 1
    fi
fi

# build and tag
function docker_build () {
    tags=("quay.io/$QUAY_PROJECT/$CONTAINER_IMAGE:$CONTAINER_TAG")
    if [ -n "$TAG_ALSO_LATEST" -a "$CONTAINER_TAG" != "latest" ]; then
        tags+=("quay.io/$QUAY_PROJECT/$CONTAINER_IMAGE:latest")
    fi

    if [ -n "$BUILD_DATE" ]; then
        docker build --build-arg=BUILD_DATE=$BUILD_DATE "${@}" -t "$CONTAINER_IMAGE:$CONTAINER_TAG" . || exit 3
    else
        docker build "${@}" -t "$CONTAINER_IMAGE:$CONTAINER_TAG" . || exit 3
    fi

    for tag in "${tags[@]}"; do
        docker tag "$CONTAINER_IMAGE:$CONTAINER_TAG" "$tag"
    done
}

# build
case $BUILD in
    local)
        docker_build "${@}"
        ;;
    quay)
        # designed to be used by travis-ci, where the docker_* variables are defined
        if [ -z "$DOCKER_PASSWORD" -o -z "$DOCKER_USERNAME" ]; then
            echo "Requires DOCKER_USERNAME and DOCKER_PASSWORD variables to be exported." >&2
            exit 1
        fi
        echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin quay.io || exit 2

        docker_build "${@}"
        for tag in "${tags[@]}"; do
            docker push "$tag" || exit 4
        done
        ;;
    *)
        print_usage >&2
        exit 126
        ;;
esac
