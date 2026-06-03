@echo off
:: Self-copy trick: run from temp so git checkout can't modify this file mid-run
if "%~1"=="__RUNNING__" goto main_logic
copy "%~f0" "%TEMP%\tenex_daily_run.bat" /Y >nul
call "%TEMP%\tenex_daily_run.bat" __RUNNING__
exit /b

:main_logic
cd /d "C:\Users\altai\Dropbox (Personal)\99 XX\00 TradingBot"

for /f %%a in ('powershell -command "Get-Date -Format yyyyMMdd"') do set DATESTR=%%a
set LOGFILE=logs\daily_%DATESTR%.log

echo =============================== >> %LOGFILE%
echo Daily focused run started: %DATE% %TIME% >> %LOGFILE%
echo =============================== >> %LOGFILE%

python run_daily.py >> %LOGFILE% 2>&1
python scripts\generate_site.py >> %LOGFILE% 2>&1
git add registry/all_results.csv registry/champion.json registry/run_log.csv docs/index.html >> %LOGFILE% 2>&1
git commit -m "Daily run: %DATESTR%" >> %LOGFILE% 2>&1
git push origin main >> %LOGFILE% 2>&1

:: Push engine code to private repo
git checkout engine >> %LOGFILE% 2>&1
git add -A >> %LOGFILE% 2>&1
git diff --cached --quiet || git commit -m "Engine update: %DATESTR%" >> %LOGFILE% 2>&1
git push private engine:main >> %LOGFILE% 2>&1
git checkout main >> %LOGFILE% 2>&1

:: Push research code to research repo
git checkout research >> %LOGFILE% 2>&1
git add -A >> %LOGFILE% 2>&1
git diff --cached --quiet || git commit -m "Research update: %DATESTR%" >> %LOGFILE% 2>&1
git push research research:main >> %LOGFILE% 2>&1
git checkout main >> %LOGFILE% 2>&1

echo Finished: %DATE% %TIME% >> %LOGFILE%
