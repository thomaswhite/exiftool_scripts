#!/bin/bash

source exiftool-common.sh

exiftool -ext jpg -ext JPG ${exif_param_NAME_ONLY} '-'"${TAG}"'<${FileModifyDate}'"${ms_camera_lens_ext}" '-'"${TAG}"'<${CreateDate}'"${ms_camera_lens_ext}" '-'"${TAG}"'<${DateTimeOriginal}'"${ms_camera_lens_ext}"  "${dir}"

