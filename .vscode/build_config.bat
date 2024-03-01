echo off

set OUTPUT_FILE_NAME=index
set INPUT_FILE_NAME=index
set DEBUG_MODE=false

if %DEBUG_MODE% EQU true goto debug

if exist dist\ (
  echo Folder "dist" is exist
) else (
  echo Creating folder "dist"...
  mkdir "dist"
)
 
echo on

%CD%\asm_modules\masm32\bin\ml /c /Fo %CD%\dist\%OUTPUT_FILE_NAME%.obj /coff %CD%\src\%INPUT_FILE_NAME%.asm
%CD%\asm_modules\masm32\bin\rc /fo %CD%\dist\%OUTPUT_FILE_NAME%.res %CD%\src\%INPUT_FILE_NAME%.rc
%CD%\asm_modules\masm32\bin\link /subsystem:windows %CD%\dist\%OUTPUT_FILE_NAME%.obj %CD%\dist\%OUTPUT_FILE_NAME%.res /out:%CD%\dist\%OUTPUT_FILE_NAME%.exe

goto end

:debug
set DEBUG_MODE_TRUE=/Zd /Zi
set DEBUG_PARAMETR=/debug
echo on
%CD%\asm_modules\masm32\bin\ml /c /Fo %CD%\dist\%OUTPUT_FILE_NAME%.obj /coff %DEBUG_MODE_TRUE% %CD%\src\%INPUT_FILE_NAME%.asm
%CD%\asm_modules\masm32\bin\rc /fo %CD%\dist\%OUTPUT_FILE_NAME%.res %CD%\src\%INPUT_FILE_NAME%.rc
%CD%\asm_modules\masm32\bin\link /subsystem:windows %DEBUG_PARAMETR% %CD%\dist\%OUTPUT_FILE_NAME%.obj %CD%\dist\%OUTPUT_FILE_NAME%.res /out:%CD%\dist\%OUTPUT_FILE_NAME%.exe

:end
pause
