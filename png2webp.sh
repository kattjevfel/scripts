#!/bin/bash
# Convert dem pngs yo!

if [ $# -eq 0 ]; then
	echo 'I feast on pngs and you'\''ve left me hungry!'
	exit
fi

# Colours! 
cres='\033[0m'		# reset
cred='\033[0;31m'	# red
cyel='\033[0;33m'	# yellow
cgrn='\033[0;32m'	# green

for file in "$@"; do
	# Filename only
	shortfile=${file##*/}
	# Dir only
	directory=${file%/*}


	# Make sure file exists
	if ! [[ -f $file ]]; then
		echo "$shortfile is not a file!"
		continue
	fi

	# Check that the PNG is not a spy
	if ! [ "$(file -b --extension "$file")" = png ]; then
		echo "$shortfile is not a PNG!"
		continue
	fi

	# Filesize before converting in bytes & human readable
	sizepre="$(stat -c '%s' "$file" 2>/dev/null)"
	sizeprehuman=$(numfmt --to=iec-i --suffix=B --format='%.1f' "$sizepre" 2>/dev/null)

	# Print current file (with path) being processed + size in human readable
	echo -n "Converting $file ($sizeprehuman)... "

	if ERROR=$({ mogrify -define webp:lossless=true -format webp "$file"; } 2>&1); then
		# Filesize after converting in bytes & human readable
		sizesuf="$(stat -c '%s' "${file%.*}".webp)"
		sizesufhuman=$(numfmt --to=iec-i --suffix=B --format='%.1f' "$sizesuf")

		# Give up if bigger than source
		if (("$sizesuf" > "$sizepre")); then
			echo -e "${cyel}done, but ${shortfile%.*}.webp is bigger than the source, deleting output!${cres}"
			rm "${file%.*}.webp"
			continue
		fi

		# Show off fancy stats!
		echo -e "done! -> ${cgrn}${shortfile%.*}.webp ($sizesufhuman, $(awk "BEGIN {print $sizesuf/$sizepre*100}")% of original size)${cres}"

		# Delete original
		rm "$file"
	else
		# Print error and exit
		echo -e "failed: ${cred}${ERROR/$directory\/}${cres}"
		continue
	fi
done
