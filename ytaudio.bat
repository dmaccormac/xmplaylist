@echo off
setlocal enabledelayedexpansion

REM ytaudio.bat
REM Plays audio from YouTube URLs using yt-dlp and ffplay.
REM Usage: ytaudio.bat [URL1 URL2 ...]
REM If no URLs are provided, reads from piped input.
REM Author: Dan MacCormac
REM Last updated: 2025-10-06


if "%~1"=="" (
    REM No arguments, read from piped input
    for /f "tokens=* delims=" %%A in ('more') do (
        yt-dlp.exe -f bestaudio "%%A" -o - | ffplay -nodisp -autoexit -i -
    )
) else (
    REM Arguments were passed
    for %%A in (%*) do (
        yt-dlp.exe -f bestaudio "%%A" -o - | ffplay -nodisp -autoexit -i -
    )
)