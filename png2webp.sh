#!/bin/bash
# Convert dem pngs yo!

if [ $# -eq 0 ]; then
	echo 'I feast on pngs and you'\''ve left me hungry!'
	exit
fi

for file in "$@"; do
	# Make sure file exists
	if ! [[ -f $file ]]; then
		echo "$file is not a file!"
		continue
	fi

	# Check that the PNG is not a spy
	if ! [ "$(file -b --extension "$file")" = png ]; then
		echo "$file is not a PNG!"
		continue
	fi

	# Filesize before converting in bytes & human readable
	sizepre="$(stat -c '%s' "$file" 2>/dev/null)"
	sizeprehuman=$(numfmt --to=iec-i --suffix=B --format='%.1f' "$sizepre" 2>/dev/null)

	# Print current file (with path) being processed + size in human readable
	echo -ne "Converting $file ($sizeprehuman)... "

	# Bash can be a nightmare at times, this is how you do STDERR redirects.
	# ..Moving on, check how the conversion went
	if ERROR=$({ mogrify -define webp:lossless=true -format webp "$file"; } 2>&1); then
		echo 'done!'

		# Filesize after converting in bytes & human readable
		sizesuf="$(stat -c '%s' "${file%.*}".webp)"
		sizesufhuman=$(numfmt --to=iec-i --suffix=B --format='%.1f' "$sizesuf")

		# Show off fancy stats!
		echo "Converted ${file%.*}.webp ($sizesufhuman) ($(awk "BEGIN {print $sizesuf/$sizepre*100}")% of original size)"

		# Delete original
		rm "$file"
	else
		echo 'failed! :('
		# Print error and exit
		echo -e "\033[0;31m$ERROR\033[0m"
		continue
	fi
done
