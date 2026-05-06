#!/bin/bash
set -euo pipefail

BIN_DIR="$( dirname "${BASH_SOURCE[0]}" )"
SRC_DIR="src"
RAWSVG_DIR="$SRC_DIR/svg"
INDEX="$SRC_DIR/index.theme"
ALIASES="$SRC_DIR/alias.list"

# Inkscape/fontconfig need writable user dirs; Nix sandboxes often point HOME at /homeless-shelter.
BUILD_PROFILE_DIR="$(mktemp -d "${TMPDIR:-/tmp}/breeze-catppuccin.XXXXXX")"
trap 'rm -rf "$BUILD_PROFILE_DIR"' EXIT
export HOME="$BUILD_PROFILE_DIR/home"
export XDG_CACHE_HOME="$BUILD_PROFILE_DIR/cache"
export XDG_CONFIG_HOME="$BUILD_PROFILE_DIR/config"
export XDG_DATA_HOME="$BUILD_PROFILE_DIR/data"
mkdir -p "$HOME" "$XDG_CACHE_HOME/fontconfig" "$XDG_CONFIG_HOME/inkscape" "$XDG_DATA_HOME"

NOMINAL_SIZE=24
REAL_SIZE=32
FRAME_TIME=30
SCALES="50 75 100 125 150 175 200 225 250 275 300"

echo -ne "Checking Requirements...\\r"
if [[ ! -d "${RAWSVG_DIR}" ]]; then
	echo -e "\\nFAIL: '${RAWSVG_DIR}' missing in /src"
	exit 1
fi

if [[ ! -f "${INDEX}" ]]; then
	echo -e "\\nFAIL: '${INDEX}' missing in /src"
	exit 1
fi

if ! command -v inkscape > /dev/null ; then
	echo -e "\\nFAIL: inkscape must be installed"
	exit 1
fi

if ! command -v xcursorgen > /dev/null ; then
	echo -e "\\nFAIL: xcursorgen must be installed"
	exit 1
fi
echo -e "\033[0KChecking Requirements... DONE"

echo -ne "Making Folders... \\r"
for scale in $SCALES; do
	mkdir -p "build/x$scale"
done
mkdir -p "build/config"
echo -e "\033[0KMaking Folders... DONE";

echo "Generating pixmaps..."
for RAWSVG in ${RAWSVG_DIR}/*.svg; do
	BASENAME=${RAWSVG##*/}
	BASENAME=${BASENAME%.*}
	genPixmaps="file-open:${RAWSVG};"

	echo -ne "    $BASENAME...\\r"

	for scale in $SCALES; do
		DIR="build/x${scale}"
		if [[ "${DIR}/${BASENAME}.png" -ot ${RAWSVG} ]]; then
			genPixmaps="${genPixmaps} export-width:$((${REAL_SIZE}*scale/100)); export-height:$((${REAL_SIZE}*scale/100)); export-filename:${DIR}/${BASENAME}.png; export-do;"
		fi
	done
	if [ "$genPixmaps" != "file-open:${RAWSVG};" ]; then
		inkscape --shell < <(echo "${genPixmaps}") > /dev/null
	fi

	echo "    $BASENAME... DONE"
done
echo "Generating pixmaps... DONE"

echo "Generating cursor theme..."
OUTPUT="$(grep --only-matching --perl-regex "(?<=Name\=).*$" $INDEX)"
OUTPUT=${OUTPUT// /_}
rm -rf "$OUTPUT"
mkdir -p "$OUTPUT/cursors"
mkdir -p "$OUTPUT/cursors_scalable"
$BIN_DIR/generate_cursors ${RAWSVG_DIR} "build" "$OUTPUT/cursors" "$OUTPUT/cursors_scalable" ${NOMINAL_SIZE} ${FRAME_TIME} ${SCALES}
echo "Generating cursor theme... DONE"

echo -ne "Generating shortcuts...\\r"
while read ALIAS ; do
	FROM=${ALIAS% *}
	TO=${ALIAS#* }

	if [[ -e "$OUTPUT/cursors/$FROM" ]]; then
		continue
	fi

	ln -s "$TO" "$OUTPUT/cursors/$FROM"
done < $ALIASES

while read ALIAS ; do
	FROM=${ALIAS% *}
	TO=${ALIAS#* }

	if [[ -e "$OUTPUT/cursors_scalable/$FROM" ]]; then
		continue
	fi

	ln -s "$TO" "$OUTPUT/cursors_scalable/$FROM"
done < $ALIASES
echo -e "\033[0KGenerating shortcuts... DONE"

echo -ne "Copying Theme Index...\\r"
	if ! [[ -e "$OUTPUT/$INDEX" ]]; then
		cp $INDEX "$OUTPUT/index.theme"
	fi
echo -e "\033[0KCopying Theme Index... DONE"

echo "COMPLETE!"
