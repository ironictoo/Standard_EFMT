@echo off
rem Double-click to show the resting state fixation cross. Press ESCAPE to close it.
rem Starts StimTool with the RESTING_STATE_FixationCross task list, skipping the StimTool dialog.
rem
rem If Python is not found, set PSYCHOPY_PYTHON below to the python.exe that you normally use to run StimTool.py.
set "PSYCHOPY_PYTHON="

cd /d "%~dp0"

if defined PSYCHOPY_PYTHON goto run
for %%P in (
    "C:\Program Files\PsychoPy\python.exe"
    "C:\Program Files\PsychoPy3\python.exe"
    "C:\Program Files (x86)\PsychoPy3\python.exe"
    "C:\Program Files (x86)\PsychoPy2\python.exe"
) do if not defined PSYCHOPY_PYTHON if exist %%P set "PSYCHOPY_PYTHON=%%~P"
if not defined PSYCHOPY_PYTHON set "PSYCHOPY_PYTHON=python"

:run
"%PSYCHOPY_PYTHON%" StimTool.py RESTING_STATE_FixationCross.TL
if errorlevel 1 pause
