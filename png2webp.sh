#!/bin/bash
# Convert dem pngs yo!

if [ $# -eq 0 ]; then
	echo 'I feast on pngs and you'\''ve left me hungry!'
	exit
fi

converter() {
	# Filesize before converting in bytes & human readable
	sizepre="$(stat -c '%s' "$1" 2>/dev/null)"
	sizeprehuman=$(numfmt --to=iec-i --suffix=B --format='%.1f' "$sizepre")

	# Print current file (with path) being processed + size in human readable
	echo -ne "Converting $1 ($sizeprehuman)... "

	# Bash can be a nightmare at times, this is how you do STDERR redirects.
	# ..Moving on, check how the conversion went
	if ERROR=$({ mogrify -define webp:lossless=true -format webp "$1"; } 2>&1); then
		echo 'done!'

		# Filesize after converting in bytes & human readable
		sizesuf="$(stat -c '%s' "${1%.*}".webp)"
		sizesufhuman=$(numfmt --to=iec-i --suffix=B --format='%.1f' "$sizesuf")

		# Show off fancy stats!
		echo "Converted ${1%.*}.webp ($sizesufhuman) ($(awk "BEGIN {print $sizesuf/$sizepre}")% of original size)"
	else
		echo 'failed! :('
		# Print error and exit
		echo -e "\033[0;31m$ERROR\033[0m"
		exit 1
	fi
}

for file in "$@"; do
	converter "$file"
done
