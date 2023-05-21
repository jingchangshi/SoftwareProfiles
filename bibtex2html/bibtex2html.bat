REM cmd /c mklink C:\Users\JingchangShi\scoop\shims\bibtex2html.bat C:\Users\JingchangShi\software_profile\bibtex2html\bibtex2html.bat
@echo off
set fname=%~n1
set fext=%~x1
python "%USERPROFILE%\scoop\apps\python37\current\Scripts\bibtex2html.py" %fname%.bib %fname%.html --nc -i "{'show_paper_style':'year'}"
