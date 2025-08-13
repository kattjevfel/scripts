#!/bin/bash
# shellcheck disable=SC2312
IFS=$'\n'

if [[ $# -eq 0 ]]; then
	echo 'I feast on images and you'\''ve left me hungry!'
	exit
fi

# Colours!
cres='\033[0m'    # reset
cred='\033[0;31m' # red
cyel='\033[0;33m' # yellow
cgrn='\033[0;32m' # green

echoerr() {
	echo >&2 -e "ERROR: ${cred}${*}${cres}"
}

for file in "$@"; do
	# Filename only
	shortfile=${file##*/}
	# Dir only
	directory=${file%/*}
	# fuck basename
	basename=${file%.*}
	# mime-type
	mimetype="$(file -b --mime-type "${file}")"

	# Make sure file exists and is a picture
	if ! [[ -f ${file} ]] || [[ "$(echo "${mimetype}" | cut -d/ -f1)" != image ]]; then
		echoerr "${shortfile} is not a valid image!"
		continue
	fi

	# Check that file is not already converted
	if [[ -f ${basename}.webp ]]; then
		echoerr "${shortfile} was already converted!"
		continue
	fi

	# Filesize before converting in bytes & human readable
	sizepre="$(stat -c '%s' "${file}" 2>/dev/null)"
	sizeprehuman=$(numfmt --to=iec-i --suffix=B --format='%.1f' "${sizepre}" 2>/dev/null)

	# Print current file (with path) being processed + size in human readable
	echo -n "Converting ${file} (${sizeprehuman})... "

	# Command to perform conversion
	# Use img2webp for all its supported formats, mogrify for anything else
	if [[ "${mimetype}" = "image/png" ]] || [[ "${mimetype}" = "image/jpeg" ]] || [[ "${mimetype}" = "image/tiff" ]]; then
		convert_command=(img2webp -lossless "${file}" -o "${basename}.webp")
	else
		convert_command=(mogrify -define webp:lossless=true -format webp "${file}")
	fi

	if ERROR=$({ "${convert_command[@]}"; } 2>&1); then
		# Filesize after converting in bytes & human readable
		sizesuf="$(stat -c '%s' "${basename}".webp)"
		sizesufhuman=$(numfmt --to=iec-i --suffix=B --format='%.1f' "${sizesuf}")

		# Give up if bigger than source
		if (("${sizesuf}" > "${sizepre}")); then
			echo >&2 -e "${cyel}done, but ${shortfile%.*}.webp is bigger than the source, deleting output!${cres}"
			rm "${basename}.webp"
			continue
		fi

		# Show off fancy stats!
		echo -e "done! -> ${cgrn}${shortfile%.*}.webp (${sizesufhuman}, $(awk "BEGIN {print ${sizesuf}/${sizepre}*100}")% of original size)${cres}"

		# Delete original
		rm "${file}"
	else
		echoerr "${ERROR/${directory}\//}"
		continue
	fi
done
