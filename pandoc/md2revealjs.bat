@echo off

if -%1-==-- echo "The markdown file not provided!" & exit /b

set pandoc=pandoc

%pandoc% -f markdown -t revealjs --template=%~dp0revealjs.template -V revealjs-url:https://cdnjs.cloudflare.com/ajax/libs/reveal.js/4.1.0 -V width=1600 -V height=900 --mathjax --slide-level=2 --toc --number-sections -o %~n1.html %1


