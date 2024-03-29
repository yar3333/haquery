@IF NOT EXIST ..\examples GOTO NO_EXAMPLES
@del examples.zip 2>NUL
@echo Zipping examples...
@7z a -tzip examples.zip ..\examples -xr!*\bin\** -xr!*\gen\**
:NO_EXAMPLES

@del flashdevelop.zip 2>NUL
@7z a -tzip flashdevelop.zip ..\flashdevelop

@del library.zip 2>NUL
@echo Zipping library...
@7z a -tzip library.zip * -i!..\*.md -xr!make-zip.cmd -xr!library.zip -xr!ndll\Windows\*.exp -xr!ndll\Windows\*.lib
