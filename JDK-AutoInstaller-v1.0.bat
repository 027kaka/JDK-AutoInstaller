@echo off
color 0a
MODE con: COLS=45 LINES=13
title JDK-AutoInstaller-v1.0
::https://github.com/KingFalse/JDK-AutoInstaller
CLS
ECHO ============================================
ECHO ���ߣ���֮����        http://kagura.me
ECHO ============================================
:init
setlocal DisableDelayedExpansion
set "batchPath=%~0"
for %%k in (%0) do set batchName=%%~nk
set "vbsGetPrivileges=%temp%\OEgetPriv_%batchName%.vbs"
setlocal EnableDelayedExpansion
:checkPrivileges
NET FILE 1>NUL 2>NUL
if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges )
:getPrivileges
if '%1'=='ELEV' (echo ELEV & shift /1 & goto gotPrivileges)
ECHO.
ECHO *******************************************
ECHO ���� UAC Ȩ����׼����
ECHO *******************************************
ECHO Set UAC = CreateObject^("Shell.Application"^) > "%vbsGetPrivileges%"
ECHO args = "ELEV " >> "%vbsGetPrivileges%"
ECHO For Each strArg in WScript.Arguments >> "%vbsGetPrivileges%"
ECHO args = args ^& strArg ^& " "  >> "%vbsGetPrivileges%"
ECHO Next >> "%vbsGetPrivileges%"
ECHO UAC.ShellExecute "!batchPath!", args, "", "runas", 1 >> "%vbsGetPrivileges%"
"%SystemRoot%\System32\WScript.exe" "%vbsGetPrivileges%" %*
exit /B
:gotPrivileges
setlocal & pushd .
cd /d %~dp0
if '%1'=='ELEV' (del "%vbsGetPrivileges%" 1>nul 2>nul  &  shift /1)
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::     ����Ϊִ��JDK��װ��������Ҫ����     ::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
IF EXIST %ProgramData%\Oracle\Java\java.settings.cfg (del /s /f /q %ProgramData%\Oracle\Java\java.settings.cfg>nul)
IF EXIST "%ProgramFiles(x86)%\Common Files\Oracle\Java\java.settings.cfg" (del /s /f /q "%ProgramFiles(x86)%\Common Files\Oracle\Java\java.settings.cfg">nul)
IF EXIST "%ProgramFiles%\Common Files\Oracle\Java\java.settings.cfg" (del /s /f /q "%ProgramFiles%\Common Files\Oracle\Java\java.settings.cfg">nul)

set "basepath="%~dp0""
::���32λJDK��װ��
for /R %basepath% %%s in (jdk-*-i586.exe) do (
echo ��⵽32λJDK
set "exe=%%~ns"
if /i "%processor_architecture%"=="x86" (
set "jdkpath=%ProgramFiles%\Java\jdk" 
set "jrepath=%ProgramFiles%\Java\jre"
) else (
set "jdkpath=%SystemDrive%\PROGRA~2\Java\jdk" 
set "jrepath=%SystemDrive%\PROGRA~2\Java\jre"
)
goto end
)

::���64λJDK��װ��
for /R %basepath% %%s in (jdk-*-x64*.exe) do (
echo ��⵽64λJDK
set exe=%%~ns
if /i "%processor_architecture%"=="x86" (
echo 32λϵͳ�޷���װ64λjdk
echo �������Oracle JDK����ҳ��...
@pause>nul
start http://www.oracle.com/technetwork/java/javase/downloads/index.html
exit
) else (
set "jdkpath=%ProgramFiles%\Java\jdk" 
set "jrepath=%ProgramFiles%\Java\jre"
)
goto end
)
echo ��ǰ·����δ��⵽JDK��װ��!
echo �������Oracle JDK����ҳ��...
@pause>nul
start http://www.oracle.com/technetwork/java/javase/downloads/index.html
exit


:end
set "absjdkpath=" 
set "absjrepath=" 
if "" neq "%absjdkpath%" (set jdkpath=%absjdkpath%)
if "" neq "%absjrepath%" (set jrepath=%absjrepath%)
::�ж��Ƿ���·������ ���ݲ�������·��
if "" neq "%1" (set jdkpath=%1)
if "" neq "%2" (set jrepath=%2)
echo JDK��װλ��:%jdkpath:PROGRA~2=ProgramFiles(x86)%
echo JRE��װλ��:%jrepath:PROGRA~2=ProgramFiles(x86)%
echo ���ڰ�װ...
::д������JDK��װ�������ļ���ʹ�������ļ�����
echo AUTO_UPDATE=Disable>%tmp%\java.settings.cfg
echo INSTALL_SILENT=Enable>>%tmp%\java.settings.cfg
echo INSTALLDIR=%jdkpath%>>%tmp%\java.settings.cfg
start %exe% installcfg=%tmp%\java.settings.cfg


::��ѭ�����ڼ��java.settings.cfg�Ƿ���ڣ����������д�ļ����ݣ����ڰ�װJRE
:loop
IF EXIST %ProgramData%\Oracle\Java\java.settings.cfg (
echo AUTO_UPDATE=Disable>"%ProgramData%\Oracle\Java\java.settings.cfg"
echo INSTALL_SILENT=Enable>>"%ProgramData%\Oracle\Java\java.settings.cfg"
echo INSTALLDIR=%jrepath%>>"%ProgramData%\Oracle\Java\java.settings.cfg"
call :wait %exe%
)
IF EXIST "%ProgramFiles(x86)%\Common Files\Oracle\Java\java.settings.cfg" (
echo AUTO_UPDATE=Disable>"%ProgramFiles(x86)%\Common Files\Oracle\Java\java.settings.cfg"
echo INSTALL_SILENT=Enable>>"%ProgramFiles(x86)%\Common Files\Oracle\Java\java.settings.cfg"
echo INSTALLDIR=%jrepath%>>"%ProgramFiles(x86)%\Common Files\Oracle\Java\java.settings.cfg"
call :wait %exe%
)
IF EXIST "%ProgramFiles%\Common Files\Oracle\Java\java.settings.cfg" (
echo AUTO_UPDATE=Disable>"%ProgramFiles%\Common Files\Oracle\Java\java.settings.cfg"
echo INSTALL_SILENT=Enable>>"%ProgramFiles%\Common Files\Oracle\Java\java.settings.cfg"
echo INSTALLDIR=%jrepath%>>"%ProgramFiles%\Common Files\Oracle\Java\java.settings.cfg"
call :wait %exe%
)
choice /t 1 /d y /n >nul
goto loop


::��ѭ�����ڵȴ���װ���̽���
:wait
tasklist|find /i "%exe%">nul
if ERRORLEVEL 1 (
goto env
) else (
choice /t 1 /d y /n >nul
goto wait
)


:env
echo �������û�������...
REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v JAVA_HOME /t REG_SZ /d "%jdkpath%" /f>nul
for /f "tokens=3" %%a in ('reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v "Path"') do Set aa=%%a
if "%aa:;%JAVA_HOME%\bin;=%"=="%aa%" (
REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v Path /t REG_EXPAND_SZ /d "%aa%;%%JAVA_HOME%%\bin;" /f>nul
)
IF EXIST %ProgramData%\Oracle\Java\java.settings.cfg (del /s /f /q %ProgramData%\Oracle\Java\java.settings.cfg>nul)
IF EXIST "%ProgramFiles(x86)%\Common Files\Oracle\Java\java.settings.cfg" (del /s /f /q "%ProgramFiles(x86)%\Common Files\Oracle\Java\java.settings.cfg">nul)
IF EXIST "%ProgramFiles%\Common Files\Oracle\Java\java.settings.cfg" (del /s /f /q "%ProgramFiles%\Common Files\Oracle\Java\java.settings.cfg">nul)
echo ��װ���!�����������������Ӧ�û�����������
echo �����������...
@pause>nul
shutdown -r -t 0
exit

