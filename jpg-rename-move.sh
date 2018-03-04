#!/bin/bash

source images.sh

exiftool -ext jpg -ext JPG $4 ${exif_param_FULL_PATH} '-'"${TAG}"'<${FileModifyDate}'"${ms_camera_lens_ext}" '-'"${TAG}"'<${CreateDate}'"${ms_camera_lens_ext}" '-'"${TAG}"'<${DateTimeOriginal}'"${ms_camera_lens_ext}"  "${dir}"

