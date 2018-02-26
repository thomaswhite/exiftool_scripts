#!/bin/bash

source exiftool-vars.sh

exiftool -ext xmp -tagsfromfile %d%f  -overwrite_original  ${exif_param_NAME_ONLY} '-'"${TAG_filename}"'<${DateTimeOriginal}'"${suffix_xmp}"  "${dir}"
exiftool -ext nef                    ${exif_param_NAME_ONLY}  '-'"${TAG_filename}"'<${DateTimeOriginal}'"${suffix}"  ${dir}




