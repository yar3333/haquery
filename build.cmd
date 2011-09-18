@echo BUILDING HAQUERY.EXE
"C:\Program Files\FlashDevelop\Tools\fdbuild\fdbuild.exe" "tools\haquery\haquery.hxproj" -compiler "d:\MyProg\_tools\motion-twin\haxe"

@echo.
@echo BUILDING ORM
"C:\Program Files\FlashDevelop\Tools\fdbuild\fdbuild.exe" "tools\orm\orm.hxproj" -compiler "d:\MyProg\_tools\motion-twin\haxe"

@echo.
@echo CLEAN LIBRARY
@rmdir /S /Q library\bin\orm
@del /Q library\bin

@echo.
@echo MOVE NEW FILES TO LIBRARY
@move tools\haquery\bin\haquery.exe library\bin
@mkdir library\bin\orm
@move tools\orm\bin\lib library\bin\orm
@move tools\orm\bin\index.php library\bin\orm
