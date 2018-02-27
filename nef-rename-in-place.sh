#!/bin/bash

source exiftool-vars.sh

exiftool -ext xmp -tagsfromfile %d%f  -overwrite_original  ${exif_param_NAME_ONLY} '-'"${TAG}"'<${DateTimeOriginal}'"${ms_camera_lens_ext_xmp}"  "${dir}"
exiftool -ext nef                    ${exif_param_NAME_ONLY}  '-'"${TAG}"'<${DateTimeOriginal}'"${ms_camera_lens_ext}"  ${dir}




