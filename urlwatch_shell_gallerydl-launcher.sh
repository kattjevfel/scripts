#!/bin/sh
/usr/bin/grep -Po "\+\Khttp.*" - | /usr/bin/gallery-dl --option output.progress=false --option output.skip=false --input-file - 
