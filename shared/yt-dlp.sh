#!/bin/bash
# yt-dlp helpers: video, audio, playlists, channels, clips, and subtitles.
#
# Install:  mise use -g yt-dlp@latest   (ffmpeg and node must also be on PATH)
# Help:     yt-help
#
# Every function takes one or more URLs. Extra yt-dlp flags can follow the
# URL, and they override the defaults here, for example:
#   ytv "https://youtu.be/ID" --no-embed-subs
#
# Files go to $YTDL_DIR (default ~/Downloads). For one command only:
#   YTDL_DIR=. yta "https://youtu.be/ID"
#
# YouTube needs a JavaScript runtime. These helpers use node, not deno.

# H.264 video + AAC audio in MP4. QuickTime and Apple devices play it.
_YTDL_FMT_H264='bv*[vcodec^=avc1]+ba[ext=m4a]/b[ext=mp4]/b'

# English subtitles: "en", "en-US", "en-GB", and named tracks such as
# "en-j3PyPqV-e1s". "en.*" also matches the automatic translations
# (en-zh-Hans, en-pt-BR, ...), and the many requests cause HTTP 429 errors.
_YTDL_SUBS='en(-[A-Za-z0-9_-]{11})?,en-(US|GB)'

# Run yt-dlp with the options that every helper shares.
_ytdl() {
  if ! command -v yt-dlp &>/dev/null; then
    if command -v mise &>/dev/null && mise which yt-dlp &>/dev/null; then
      mise exec -- yt-dlp --js-runtimes node -N 4 -P "${YTDL_DIR:-$HOME/Downloads}" "$@"
      return
    fi
    echo "Error: yt-dlp is not installed. Install it with: mise use -g yt-dlp@latest" >&2
    return 1
  fi
  if ! command -v node &>/dev/null; then
    echo "Warning: node is not on PATH. YouTube downloads can fail or miss formats." >&2
  fi
  if ! command -v ffmpeg &>/dev/null; then
    echo "Warning: ffmpeg is not on PATH. Merging, audio extraction, and clips will fail." >&2
  fi
  yt-dlp --js-runtimes node -N 4 -P "${YTDL_DIR:-$HOME/Downloads}" "$@"
}

# Print the usage line and return 1 when the caller gives no arguments.
_ytdl_need_args() {
  local usage="$1"
  shift
  if [ $# -eq 0 ]; then
    echo "Usage: $usage" >&2
    return 1
  fi
}

# --- Video -------------------------------------------------------------------

# Best H.264 MP4 (up to 1080p on YouTube) with English subtitles,
# chapters, metadata, and a thumbnail. File name: "<title>.mp4".
ytv() {
  _ytdl_need_args "ytv <url>... [yt-dlp flags]" "$@" || return 1
  _ytdl -f "$_YTDL_FMT_H264" --merge-output-format mp4 \
    --embed-metadata --embed-thumbnail --embed-subs --sub-langs "$_YTDL_SUBS" \
    -o "%(title)s.%(ext)s" "$@"
}

# Highest quality, any codec (4K, VP9, or AV1). MKV holds every codec.
# QuickTime possibly cannot play the result. Use VLC or IINA.
ytv-best() {
  _ytdl_need_args "ytv-best <url>... [yt-dlp flags]" "$@" || return 1
  _ytdl -f "bv*+ba/b" --merge-output-format mkv \
    --embed-metadata --embed-thumbnail --embed-subs --sub-langs "$_YTDL_SUBS" \
    -o "%(title)s.%(ext)s" "$@"
}

# H.264 MP4 with a maximum height, for example: ytv-res 720 <url>
ytv-res() {
  if [ $# -lt 2 ] || ! [[ "$1" =~ ^[0-9]+$ ]]; then
    echo "Usage: ytv-res <height> <url>... [yt-dlp flags]   (example: ytv-res 720 <url>)" >&2
    return 1
  fi
  local h="$1"
  shift
  _ytdl -f "bv*[vcodec^=avc1][height<=$h]+ba[ext=m4a]/b[ext=mp4][height<=$h]/b[height<=$h]" \
    --merge-output-format mp4 \
    --embed-metadata --embed-thumbnail --embed-subs --sub-langs "$_YTDL_SUBS" \
    -o "%(title)s.%(ext)s" "$@"
}

# Part of a video. Times use seconds or [HH:]MM:SS.
#   ytclip <url> 1:30 2:45
ytclip() {
  if [ $# -lt 3 ]; then
    echo "Usage: ytclip <url> <start> <end> [yt-dlp flags]   (example: ytclip <url> 1:30 2:45)" >&2
    return 1
  fi
  local url="$1" start="$2" end="$3"
  shift 3
  _ytdl -f "$_YTDL_FMT_H264" --merge-output-format mp4 --embed-metadata \
    --download-sections "*${start}-${end}" --force-keyframes-at-cuts \
    -o "%(title)s (clip %(section_start)ds-%(section_end)ds).%(ext)s" "$url" "$@"
}

# --- Audio -------------------------------------------------------------------

# MP3 (best VBR quality) with metadata and the thumbnail as cover art.
yta() {
  _ytdl_need_args "yta <url>... [yt-dlp flags]" "$@" || return 1
  _ytdl -f "ba/b" -x --audio-format mp3 --audio-quality 0 \
    --embed-metadata --embed-thumbnail \
    -o "%(title)s.%(ext)s" "$@"
}

# M4A (AAC). YouTube serves AAC, so there is usually no re-encode and no
# quality loss. Apple Music and iOS play it.
yta-m4a() {
  _ytdl_need_args "yta-m4a <url>... [yt-dlp flags]" "$@" || return 1
  _ytdl -f "ba[ext=m4a]/ba/b" -x --audio-format m4a \
    --embed-metadata --embed-thumbnail \
    -o "%(title)s.%(ext)s" "$@"
}

# --- Playlists and channels --------------------------------------------------
# These record each downloaded video in an archive file in $YTDL_DIR. Run the
# same command again later to get only the new videos. To ignore the archive,
# add --no-download-archive.

# Full playlist as H.264 MP4: "<playlist>/001 - <title>.mp4"
ytpl() {
  _ytdl_need_args "ytpl <playlist-url>... [yt-dlp flags]" "$@" || return 1
  _ytdl -f "$_YTDL_FMT_H264" --merge-output-format mp4 \
    --embed-metadata --embed-thumbnail --embed-subs --sub-langs "$_YTDL_SUBS" \
    --yes-playlist --ignore-errors \
    --download-archive "${YTDL_DIR:-$HOME/Downloads}/.ytdl-archive-video.txt" \
    -o "%(playlist_title|Playlist)s/%(playlist_index)03d - %(title)s.%(ext)s" "$@"
}

# Full playlist as MP3, tagged like an album (album = playlist title,
# track = playlist position): "<playlist>/001 - <title>.mp3"
ytpl-audio() {
  _ytdl_need_args "ytpl-audio <playlist-url>... [yt-dlp flags]" "$@" || return 1
  _ytdl -f "ba/b" -x --audio-format mp3 --audio-quality 0 \
    --embed-metadata --embed-thumbnail \
    --parse-metadata "playlist_title:%(album)s" \
    --parse-metadata "playlist_index:%(track_number)s" \
    --yes-playlist --ignore-errors \
    --download-archive "${YTDL_DIR:-$HOME/Downloads}/.ytdl-archive-audio.txt" \
    -o "%(playlist_title|Playlist)s/%(playlist_index)03d - %(title)s.%(ext)s" "$@"
}

# All videos of a channel as H.264 MP4: "<channel>/<YYYY-MM-DD> - <title>.mp4"
# Give the /videos URL to skip Shorts and live streams:
#   ytch "https://www.youtube.com/@mitocw/videos"
# The sleep flags slow the requests, so that YouTube does not block you.
ytch() {
  _ytdl_need_args "ytch <channel-url>... [yt-dlp flags]" "$@" || return 1
  _ytdl -f "$_YTDL_FMT_H264" --merge-output-format mp4 \
    --embed-metadata --embed-thumbnail --embed-subs --sub-langs "$_YTDL_SUBS" \
    --ignore-errors --sleep-requests 1 --sleep-interval 2 --max-sleep-interval 6 \
    --download-archive "${YTDL_DIR:-$HOME/Downloads}/.ytdl-archive-video.txt" \
    -o "%(channel|uploader)s/%(upload_date>%Y-%m-%d)s - %(title)s.%(ext)s" "$@"
}

# All videos of a channel as MP3: "<channel>/<YYYY-MM-DD> - <title>.mp3"
ytch-audio() {
  _ytdl_need_args "ytch-audio <channel-url>... [yt-dlp flags]" "$@" || return 1
  _ytdl -f "ba/b" -x --audio-format mp3 --audio-quality 0 \
    --embed-metadata --embed-thumbnail \
    --ignore-errors --sleep-requests 1 --sleep-interval 2 --max-sleep-interval 6 \
    --download-archive "${YTDL_DIR:-$HOME/Downloads}/.ytdl-archive-audio.txt" \
    -o "%(channel|uploader)s/%(upload_date>%Y-%m-%d)s - %(title)s.%(ext)s" "$@"
}

# --- Extras ------------------------------------------------------------------

# Subtitles only, as SRT. Uses the automatic captions if there are no others.
# Change the language: ytsubs <url> --sub-langs es
ytsubs() {
  _ytdl_need_args "ytsubs <url>... [yt-dlp flags]" "$@" || return 1
  _ytdl --skip-download --write-subs --write-auto-subs --sub-langs "$_YTDL_SUBS" \
    --convert-subs srt -o "%(title)s.%(ext)s" "$@"
}

# Thumbnail only, as JPG.
ytthumb() {
  _ytdl_need_args "ytthumb <url>... [yt-dlp flags]" "$@" || return 1
  _ytdl --skip-download --write-thumbnail --convert-thumbnails jpg \
    -o "%(title)s.%(ext)s" "$@"
}

# Show the title, channel, length, date, and license. Downloads nothing.
ytinfo() {
  _ytdl_need_args "ytinfo <url>..." "$@" || return 1
  _ytdl --skip-download --no-playlist \
    --print "Title:    %(title)s" \
    --print "Channel:  %(channel|uploader)s" \
    --print "Length:   %(duration_string)s" \
    --print "Uploaded: %(upload_date>%Y-%m-%d)s" \
    --print "License:  %(license|unknown)s" \
    --print "URL:      %(webpage_url)s" "$@"
}

# List every format that is available (codec, resolution, size).
# Then pick one: ytv <url> -f <id>
ytformats() {
  _ytdl_need_args "ytformats <url>" "$@" || return 1
  _ytdl -F --no-playlist "$@"
}

# YouTube changes often. Update yt-dlp first when a download fails.
ytdl-update() {
  mise use -g yt-dlp@latest && mise exec -- yt-dlp --version
}

# Cheatsheet for all the helpers in this file.
yt-help() {
  local dl_dir="${YTDL_DIR:-$HOME/Downloads}"
  local ver
  ver="$(yt-dlp --version 2>/dev/null || mise exec -- yt-dlp --version 2>/dev/null || echo 'not installed')"
  cat <<EOF
yt-dlp cheatsheet                           yt-dlp: $ver
Files go to: $dl_dir

VIDEO
  ytv <url>                      H.264 MP4, up to 1080p. Plays in QuickTime.
  ytv-best <url>                 Highest quality, any codec (4K). MKV file.
  ytv-res <height> <url>         H.264 MP4, maximum height (720, 480).
  ytclip <url> <start> <end>     Part of a video. Times: seconds or [HH:]MM:SS.

AUDIO
  yta <url>                      MP3 (best quality) with cover art and tags.
  yta-m4a <url>                  M4A (AAC). Usually no quality loss.

PLAYLISTS AND CHANNELS
  ytpl <url>                     Playlist as MP4: <playlist>/001 - <title>.mp4
  ytpl-audio <url>               Playlist as MP3, tagged as an album
  ytch <url>                     Channel as MP4: <channel>/<date> - <title>.mp4
  ytch-audio <url>               Channel as MP3: <channel>/<date> - <title>.mp3

EXTRAS
  ytsubs <url>                   English subtitles only, as SRT.
  ytthumb <url>                  Thumbnail only, as JPG.
  ytinfo <url>                   Title, channel, length, license. No download.
  ytformats <url>                List all formats (ID, codec, resolution, size).
  ytdl-update                    Update yt-dlp with mise.
  yt-help                        Show this cheatsheet.

EXAMPLES
  ytv https://youtu.be/ID                         One video
  ytv URL1 URL2 URL3                              More than one video
  ytv-res 720 https://youtu.be/ID                 Smaller file
  ytclip https://youtu.be/ID 1:30 2:45            1:30 to 2:45 only
  yta https://youtu.be/ID                         Audio only
  ytpl "https://www.youtube.com/playlist?list=ID" Full playlist
  ytch "https://www.youtube.com/@name/videos"     Channel, no Shorts or lives
  YTDL_DIR=. ytv https://youtu.be/ID              Save in the current folder

EXTRA FLAGS (add after the URL; they override the defaults)
  --playlist-items 1-5           Only items 1 to 5 of a playlist or channel
  --dateafter 20260101           Only videos uploaded on or after this date
  --max-downloads 10             Stop after 10 downloads
  --no-embed-subs                No subtitles in the file
  --sub-langs es                 Spanish subtitles (ytsubs, ytv, ...)
  --no-download-archive          Download again, ignore the archive
  --simulate --print filename    Show the file names, download nothing
  -f <id>                        Use a format ID from ytformats

TIPS
  - Put a URL in quotes when it has ? or &. zsh changes these characters.
  - Playlist and channel commands keep an archive in the download folder:
      .ytdl-archive-video.txt   .ytdl-archive-audio.txt
    Run the same command again to get only the new videos.
  - A download fails or shows "HTTP Error 403/429"? Run ytdl-update first.
    For 429, wait some minutes before you try again.
  - Needs ffmpeg and node on PATH. These helpers use node, not deno.
EOF
}
