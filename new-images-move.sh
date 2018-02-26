#!/bin/bash

source exiftool-vars.sh

images_root="${2:-/media/tom/4Tb_Seagate/Images/}"
full_name="${images_root}/${images_dirirectory}/${format_file_name}"
exif_param_FULL_PATH="-m -r -progress -d ${full_name}" 

exiftool -ext jpg -ext JPG $4 ${exif_param_FULL_PATH}   '-'"${TAG_filename}"'<${DateTimeOriginal}'"${suffix}"  "${dir}" 
exiftool -ext nef -ext NEF $4  ${exif_param_FULL_PATH}  '-'"${TAG_filename}"'<${DateTimeOriginal}'"${suffix}"  ${dir}

