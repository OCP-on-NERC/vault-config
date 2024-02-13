#!/bin/sh

find . -type f \( -name '*.jsonnet' -o -name '*.libsonnet' \) -print0 |
	xargs -0 jsonnetfmt -i
