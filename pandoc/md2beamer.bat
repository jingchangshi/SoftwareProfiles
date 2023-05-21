@echo off

if -%1-==-- echo "The markdown file not provided!" & exit /b

set pandoc=pandoc

%pandoc% -f markdown -t beamer --pdf-engine=xelatex -V mainfont="Inziu Iosevka SC" -V CJKmainfont="Inziu Iosevka SC" -V monofont="Cascadia Mono" -V monofontoptions=Weight=ExtraLight -V mathfont="Fira Math" -V mathfontoptions=Scale=1.1 -V theme=uniud --slide-level=2 --toc --number-sections -V classoption=t -V aspectratio=169 --include-in-header=%~dp0beamer_header.tex -o %~n1.pdf %1

