@echo off

if -%1-==-- echo "The markdown file not provided!" & exit /b

set pandoc=C:\Users\JingchangShi\AppData\Local\Pandoc\pandoc.exe
set template_file=journal.windows10.local.template
set template_path=%~dp0%template_file%

%pandoc% -f markdown -t html  --template=%template_path% --mathjax --number-sections --number-offset=0 %1 -o %~n1.html