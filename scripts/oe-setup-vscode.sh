#!/bin/sh

usage() {
    echo "$0 <OEINIT> <BUILDDIR>"
    echo "  OEINIT:   path to directory where the .vscode folder is"
    echo "  BUILDDIR: directory passed to the oe-init-setup-env script"
}

if [ "$#" -ne 2 ]; then
    usage
    exit 1
fi

OEINIT=$(readlink -f "$1")
BUILDDIR=$(readlink -f "$2")
VSCODEDIR=$OEINIT/.vscode

if [ ! -d "$OEINIT" ] || [ ! -d "$BUILDDIR" ]; then
    echo "$OEINIT and/or $BUILDDIR directories are not present."
    exit 1
fi

VSCODE_SETTINGS=$VSCODEDIR/settings.json
ws_builddir="$(echo "$BUILDDIR" | sed -e "s|$OEINIT|\${workspaceFolder}|g")"

# If BUILDDIR is in scope of VSCode ensure VSCode does not try to index the build folder.
# This would lead to a busy CPU and finally to an OOM exception.
mkdir -p "$VSCODEDIR"
cat <<EOMsettings > "$VSCODE_SETTINGS"
{
    "bitbake.pathToBitbakeFolder": "\${workspaceFolder}/bitbake",
    "bitbake.pathToEnvScript": "\${workspaceFolder}/oe-init-build-env",
    "bitbake.pathToBuildFolder": "$ws_builddir",
    "bitbake.commandWrapper": "",
    "bitbake.workingDirectory": "\${workspaceFolder}",
    "files.exclude": {
        "**/.git/**": true,
        "**/_build/**": true,
        "**/buildhistory/**": true,
        "**/cache/**": true,
        "**/downloads/**": true,
        "**/node_modules/**": true,
        "**/oe-logs/**": true,
        "**/oe-workdir/**": true,
        "**/sstate-cache/**": true,
        "**/tmp*/**": true,
        "**/workspace/attic/**": true,
        "**/workspace/sources/**": true
    },
    "files.watcherExclude": {
        "**/.git/**": true,
        "**/_build/**": true,
        "**/buildhistory/**": true,
        "**/cache/**": true,
        "**/downloads/**": true,
        "**/node_modules/**": true,
        "**/oe-logs/**": true,
        "**/oe-workdir/**": true,
        "**/sstate-cache/**": true,
        "**/tmp*/**": true,
        "**/workspace/attic/**": true,
        "**/workspace/sources/**": true
    },
    "python.analysis.exclude": [
        "**/_build/**",
        "**/.git/**",
        "**/buildhistory/**",
        "**/cache/**",
        "**/downloads/**",
        "**/node_modules/**",
        "**/oe-logs/**",
        "**/oe-workdir/**",
        "**/sstate-cache/**",
        "**/tmp*/**",
        "**/workspace/attic/**",
        "**/workspace/sources/**"
    ]
}
EOMsettings


# Ask the user if the yocto-bitbake extension should be installed
VSCODE_EXTENSIONS=$VSCODEDIR/extensions.json
cat <<EOMextensions > "$VSCODE_EXTENSIONS"
{
    "recommendations": [
        "yocto-project.yocto-bitbake"
    ]
}
EOMextensions

echo "You had no $VSCODEDIR configuration."
echo "These configuration files have therefore been created for you."