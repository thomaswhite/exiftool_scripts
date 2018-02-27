#!/bin/bash

source exiftool-vars.sh

images_root="${2:-/media/tom/4Tb_Seagate/Images/}"
image_full_directory_name="${images_root}/${image_directory}/${image_name}"
exif_param_FULL_PATH="-m -r -progress -d ${image_full_directory_name}"

exiftool -ext jpg -ext JPG $4 ${exif_param_FULL_PATH}   '-'"${TAG}"'<${DateTimeOriginal}'"${ms_camera_lens_ext}"  "${dir}"
exiftool -ext nef -ext NEF $4  ${exif_param_FULL_PATH}  '-'"${TAG}"'<${DateTimeOriginal}'"${ms_camera_lens_ext}"  ${dir}

