TIMEOUT /T 5 /nobreak >nul
move /y new-keypress-osd.exe %1 >nul
TIMEOUT /T 1 /nobreak >nul
start %1 >nul