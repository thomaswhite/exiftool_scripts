#!/bin/bash

source exiftool-vars.sh

exiftool -ext jpg -ext JPG $4 ${exif_param_FULL_PATH} '-'"${TAG_filename}"'<${FileModifyDate}'"${suffix}" '-'"${TAG_filename}"'<${CreateDate}'"${suffix}" '-'"${TAG_filename}"'<${DateTimeOriginal}'"${suffix}"  "${dir}" 

