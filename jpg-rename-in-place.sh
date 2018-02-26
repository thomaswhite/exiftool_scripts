#!/bin/bash

source exiftool-vars.sh

exiftool -ext jpg -ext JPG ${exif_param_NAME_ONLY} '-'"${TAG_filename}"'<${FileModifyDate}'"${suffix}" '-'"${TAG_filename}"'<${CreateDate}'"${suffix}" '-'"${TAG_filename}"'<${DateTimeOriginal}'"${suffix}"  "${dir}"

