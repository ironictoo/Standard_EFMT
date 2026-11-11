### Go to [wiki](https://github.com/Hannah-Savage/Standard_EFMT/wiki/0.-Standard-Emotional-Face-Matching-Task-(EFMT)-wiki) for installation and running the Standard version of the Emotional Face Matching Task (EFMT).

### You can contribute to the Discussion Board [here](https://github.com/Hannah-Savage/Standard_EFMT/discussions)

## Resting state fixation cross

StimTool can also show a fixed cross for resting state fMRI. The cross (the same one used in the fixation blocks of the EFMT) appears on the participant screen as soon as it is launched and stays there until the proctor presses **Escape**. There are no instructions, no wait for the scanner trigger and no time limit.

### How to launch it

Use whichever of these is most convenient:

1. **Double-click `Run_RestingState.bat`** in the StimTool folder. The cross comes up straight away, with no dialogs. You can make a desktop shortcut to this file.
   - If the window closes with a "python is not recognized" message, open `Run_RestingState.bat` in Notepad and put the full path of the `python.exe` you normally use to run StimTool between the quotes on the `set "PSYCHOPY_PYTHON="` line, e.g. `set "PSYCHOPY_PYTHON=C:\Program Files\PsychoPy\python.exe"`.
2. **From the StimTool dialog:** start StimTool as usual, enter the Subject ID and Administrator ID, choose `RESTING_STATE_FixationCross.TL` under *Experiment Order* and click OK.
3. **From free mode:** choose `free` under *Experiment Order*, then pick `RestingState` from the *Program* list.

### How to run it

1. Launch the cross before starting the resting state sequence on the scanner.
2. Start the scan.
3. When the scan has finished, press **Escape** on the stimulus computer keyboard to close the cross.

### Notes

- The cross uses the same screen and window settings (`screen_x`, `screen_y`, etc. in `Default.params`) as the EFMT, so no extra setup is needed.
- A small log (`<SubjectID>-<session>-REST-R1-_BEH.csv`) with the time the cross appeared and the time Escape was pressed is saved in `output_dir`. If that folder cannot be written to, the cross is still shown and no log is saved.
- `Run_RestingState.bat` skips the StimTool dialog, so the log is saved under the last Subject ID entered in StimTool. Use the StimTool dialog (option 2) if you need the log saved under a specific Subject ID.
- No new software is required: the resting state cross uses the same PsychoPy installation as the EFMT.
