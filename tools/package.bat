@echo off

:: Variables define
set remoteRootDir=..\..\..\10-common
set remoteJniLibDir=%remoteRootDir%\lib\release\android
set remoteJarDir=%remoteJniLibDir%\jar
set remoteApkDir=%remoteRootDir%\version
set jniLibDir=.\skyWalker\src\main\jniLibs\armeabi-v7a
set jarDir=.\skyWalker\libs
set apkDir=..\..\..\Outputs\skyWalker\outputs\apk

set jarList=kdmediasdk.jar 

set jniLibList=libinterface.so ^
libkdvmedianet.so ^
libmediasdk.so ^
libosp.so ^
libkdv323adapter.so ^
libkdv323stack.so ^
libkprop.so ^
libkdvlog.so ^
libkdvsipstack2.so ^
libkdvsipadapter2.so ^
libkdvsdp.so ^
libkdvdatanet.so ^
libkdvsipmodule2.so ^
libgnustl_shared.so ^
libbfcp.so ^
libkdcrypto.so ^
libkdssl.so ^
libkdvsrtp.so ^
libkdvsecbiz.so ^
libpfc.so 

set apkList=Skywalker-release.apk ^
Skywalker-debug.apk ^
TrueTouch-release.apk ^
TrueTouch-debug.apk ^
NewVersion-release.apk ^
NewVersion-debug.apk

set errorPromptPrefix=###### ERROR:
set "TAB=    "

echo/ 
echo [%date% %time%] ##############################################################
echo [%date% %time%] ################## Starting package... #######################
echo [%date% %time%] ##############################################################

:: Process
echo/ 
echo [%date% %time%]================== Updating jars... ===========================
call :copyFiles %remoteJarDir% %jarDir% %jarList% 
if %ERRORLEVEL% NEQ 0 (
	echo %errorPromptPrefix% Update jars failed!
	goto END
)

echo/
echo [%date% %time%]================== Updating jni libs... ===========================
call :copyFiles %remoteJniLibDir% %jniLibDir% %jniLibList% 
if %ERRORLEVEL% NEQ 0 (
	echo %errorPromptPrefix% Update jni Libs failed!
	goto END
)

echo/
echo [%date% %time%]================== Cleaning project... ===========================
call :cleanProj
if %ERRORLEVEL% NEQ 0 (
	echo %errorPromptPrefix% Clean project failed!
	goto END
)

echo/
echo [%date% %time%]================== Packaging release... ===========================
call :packageRelease
if %ERRORLEVEL% NEQ 0 (
	echo %errorPromptPrefix% Package release failed!
	goto END
)

echo/
echo [%date% %time%]================== Packaging debug... ===========================
call :packageDebug
if %ERRORLEVEL% NEQ 0 (
	echo %errorPromptPrefix% Package debug failed!
	goto END
)

echo/
echo [%date% %time%]================== Moving package... ===========================
call :copyFiles %apkDir% %remoteApkDir% %apkList%
if %ERRORLEVEL% NEQ 0 (
	echo %errorPromptPrefix% Move package failed!
	goto END
)

echo/
echo [%date% %time%]================== Commiting... ===========================
call :commitSvn
if %ERRORLEVEL% NEQ 0 (
	echo %errorPromptPrefix% Commit failed!
	goto END
)

echo/
echo [%date% %time%]================== Finished ===========================
goto END



:: Functions define
:cleanProj
call gradle clean --offline
goto:eof

:packageRelease
call gradle assembleRelease --offline
goto:eof

:packageDebug
call gradle assembleDebug --offline
goto:eof

:commitSvn
::call svn add %jniLibDir%\libpfc.so
call svn commit %jarDir% %jniLibDir% --force-log -F commitLibs.log
call svn commit %remoteApkDir% --force-log -F commitVersion.log
goto:eof

rem Need parameter: srcDir dstDir fileList
:copyFiles
setlocal EnableDelayedExpansion
set srcDir=%~1
set dstDir=%~2
set /a count=0
for %%k in (%*) do (
	set /a count=!count!+1
	if !count! GTR 2 (
		set srcFile=%srcDir%\%%k
		set dstFile=%dstDir%\%%k
		if not exist !srcFile! (
			echo %errorPromptPrefix% !srcFile! not found!
			exit /b 1
		) else (
			copy !srcFile! !dstFile! >NUL
			echo Copied !srcFile! to !dstFile!.
		)
	)
)
endlocal
goto:eof

:END
echo/
echo [%date% %time%] ##############################################################
echo [%date% %time%] ########################     END    ##########################
echo [%date% %time%] ##############################################################
