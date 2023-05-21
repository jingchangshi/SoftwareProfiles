@echo off

if -%1-==-- echo "The markdown file not provided!" & exit /b

set pandoc=pandoc
set template_file=article.tufte.template
set template_path=%~dp0%template_file%

%pandoc% -f markdown -t html  --template=%template_path% --mathjax --number-sections --number-offset=0 --toc --standalone --highlight-style=haddock %1 -o %~n1.html
