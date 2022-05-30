#!/bin/sh
set -o errexit

if [ "$#" != 2 ]; then
    >&2 echo usage: "$0" config_dir hostname
    exit 1
fi

TARGET_HOST=$2
PROJ_ROOT=$(readlink -f "$1")
SHARED=$PROJ_ROOT/base
PATCHFILE=$PROJ_ROOT/patches/$TARGET_HOST.patch

function load_conf() {
    cp -aT "$SHARED" "$TMP"
    if [ -r "$PATCHFILE" ]; then
        patch -u -p0 -d "$TMP" -i "$PATCHFILE"
    fi
}

function save_conf() {
    local RET=0
    (cd "$SHARED" && diff -ruN . "$TMP" > "$PATCHFILE") || RET=$?
    # diff returns zero if inputs are the same
    local SHORT=$(realpath --relative-to="$PROJ_ROOT" "$PATCHFILE")
    if [ "$RET" = 0 ]; then
        rm "$PATCHFILE"
        echo "Saved changes to $SHORT (empty)."
    else
        echo "Saved changes to $SHORT."
    fi
}

function run_scripts() {
    for e in "$PROJ_ROOT"/pre_install/*; do
        if [ -x "$e" ]; then
            local RET=0
            export DEPLOY_HOST=$TARGET_HOST
            export DEPLOY_ROOT=$TMP
            echo "Running $e..."
            (cd "$TMP" && "$e") || RET=$?
            if [ "$RET" != 0 ]; then
                local SHORT=$(realpath --relative-to="$PROJ_ROOT" "$e")
                >&2 echo "Error: $SHORT returned $RET. Aborting."
                exit 2
            fi
        fi
    done
}

function cleanup() { rm -rf "$TMP"; }


function main_deploy() {
    TMP=$(mktemp -d)
    trap cleanup EXIT
    load_conf
    run_scripts
    local RET=0
    if [ -z "$SKIP_PREVIEW" ]; then
        echo
        echo 'Starting a shell to preview files...'
        echo "These will be copied to $TARGET_HOST as-is."
        echo 'Changes made here will be copied to host but will not be saved locally.'
        echo 'Type `exit 0` to continue, `exit 1` to abort.'
        (cd "$TMP" && bash) || RET=$?
    fi
    if [ "$RET" = 0 ]; then
        echo "Copying files to $TARGET_HOST... (not really)"
        for e in "$PROJ_ROOT"/post_install/*; do
            if [ -x "$e" ]; then
                local SHORT=$(realpath --relative-to="$PROJ_ROOT" "$e")
                echo "Running $SHORT on $TARGET_HOST... (not really)"
            fi
        done
        echo "Done."
    else
        echo "Aborting."
    fi
}

function main_edit_patch() {
    TMP=$(mktemp -d)
    trap cleanup EXIT
    load_conf
    echo
    echo 'Starting a shell to edit files...'
    echo 'Type `exit 0` to continue, `exit 1` to abort.'
    (cd "$TMP" && bash) || true
    save_conf
}

PROG_NAME=$(basename "$0")
if [ "$PROG_NAME" = "deploy.sh" ]; then
    main_deploy
elif [ "$PROG_NAME" = "edit_patch.sh" ]; then
    main_edit_patch
else
    >&2 echo "Error: unknown basename $PROG_NAME. Aborting."
    exit 1
fi
