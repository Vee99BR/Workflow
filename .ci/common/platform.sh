#!/bin/sh -e

# SPDX-FileCopyrightText: Copyright 2025 Eden Emulator Project
# SPDX-License-Identifier: GPL-3.0-or-later

# platform handling

uname -s

case "$(uname -s)" in
	Linux*)
		PLATFORM=linux
		STANDALONE=OFF
		FFMPEG=ON
		OPENSSL=ON
        SUPPORTS_TARGETS=ON
		;;
	Darwin*)
		PLATFORM=macos
		STANDALONE=OFF
		FFMPEG=OFF
		OPENSSL=OFF
		export LIBVULKAN_PATH="/opt/homebrew/lib/libvulkan.1.dylib"
		;;
	CYGWIN*|MINGW*)
		PLATFORM=win
		STANDALONE=ON
		OPENSSL=ON
		FFMPEG=ON
        [ "$COMPILER" = "clang" ] && SUPPORTS_TARGETS=ON

		# LTO is completely broken on MSVC
		LTO=off
		;;
    MSYS*)
        PLATFORM=msys
        STANDALONE=ON
        OPENSSL=ON
        FFMPEG=ON
        SUPPORTS_TARGETS=ON
        ;;
	FreeBSD*)
		PLATFORM=freebsd
		STANDALONE=OFF
		FFMPEG=OFF
		OPENSSL=ON
        SUPPORTS_TARGETS=ON
		;;
	*)
		echo "Unknown platform $(uname -s)"
		exit 1 ;;
esac

export PLATFORM
export STANDALONE
export LTO
export FFMPEG
export OPENSSL
export SUPPORTS_TARGETS