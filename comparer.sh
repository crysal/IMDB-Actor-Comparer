#!/bin/bash
#also shout out to shellcheck.net
#This is web scraper because the only API I could find was 150k$ a' year.
#dont you just love functions?, They seem pretty POG to me, will try to use them more often. The one thing I dont like about functions is that yo are supposed to put them at the start of the script
html_getter() {
    local imdb_id="$1"
    local output_file="html_$imdb_id.txt"
    local cast_url="https://www.imdb.com/title/$imdb_id/fullcredits"

    if [ ! -f "$output_file" ]; then
        curl -s -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; rv:121.0) Gecko/20100101 Firefox/121.0" "$cast_url" > "$output_file"
    fi
    echo "$output_file"
}

cast_getter() {
    local html_file="$1"
    if [ ! -f "${html_file//.txt/_cast.txt}" ]; then
        grep "primary_photo" -A 2 "$html_file" | grep -o 'title=".*" s' | sed 's/s$\|title=\|"//g' > "${html_file//.txt/_cast.txt}"
    fi
}

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <imdb_id_show_X> <imdb_id_show_Y>"
    exit 1
fi

imdb_id_X="$1"
imdb_id_Y="$2"
html_file_X=$(html_getter "$imdb_id_X")
html_file_Y=$(html_getter "$imdb_id_Y")
cast_getter "$html_file_X"
cast_getter "$html_file_Y"

##Thinking about just doing the top 50 actors from X show, maybe adding it as an augment?
common_actors=$(comm -12 <(sort "${html_file_X//.txt/_cast.txt}") <(sort "${html_file_Y//.txt/_cast.txt}"))

if [ -n "$common_actors" ]; then
    echo "Common actors in shows with IMDb IDs $imdb_id_X and $imdb_id_Y:"
    echo "$common_actors"
else
    echo "No common actors found."
fi
