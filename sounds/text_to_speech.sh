#!/usr/bin/env bash
cat text_to_speech_list.txt | espeak --stdin -s 120 -p 60 -z -v "english-us" -w text_to_speech_list.wav
#cat text_to_speech_list.txt | festival  --tts
