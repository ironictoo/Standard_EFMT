# Standard Emotional Face Matching Task (EFMT)

A standard version of the Hariri emotional face matching task for fMRI, from
Savage et al. (2026). On each trial the participant sees one face (or shape)
at the top and two below, and presses a button to choose the bottom image that
shows the **same emotion** as the top face (or the same shape).

This is `ironictoo/Standard_EFMT`, a fork of
[Hannah-Savage/Standard_EFMT](https://github.com/Hannah-Savage/Standard_EFMT).
The `linux` branch runs on Linux with current PsychoPy, loads the licensed
NimStim faces from a folder outside the repo, and is set up for our scanner
laptop (button box keys `a`–`d`, trigger `t`, one cloned screen). Upstream
documentation:

- [Upstream wiki](https://github.com/Hannah-Savage/Standard_EFMT/wiki/0.-Standard-Emotional-Face-Matching-Task-(EFMT)-wiki)
  (installation on Windows, running, reading the output)
- [Upstream discussion board](https://github.com/Hannah-Savage/Standard_EFMT/discussions)

## Citation

- Savage, H. S., Schlüter, L., Russo, R., Leaning, I., Beckmann, C. F., &
  Marquand, A. F. (2026). Do you match what I match? A systematic review of
  over 20 years of the emotional face matching task reveals vast
  inconsistencies in design and implementation. *Human Brain Mapping*, 47(14),
  e70636. https://doi.org/10.1002/hbm.70636
- Faces: Tottenham, N., et al. (2009). The NimStim set of facial expressions:
  judgments from untrained research participants. *Psychiatry Research*,
  168(3), 242–249.
- The code builds on the Laureate Institute for Brain Research's
  [HARIRI-Task](https://github.com/laureate-institute-for-brain-research/HARIRI-Task).

## Task design

| | Practice | Scan |
| --- | --- | --- |
| Blocks | 1 shape block, then 1 face block (6 trials each) | 5 shape blocks (5 trials each) alternating with 4 face blocks (6 trials each: 3 fearful, 3 angry), starting with shapes |
| Trial | 5 s (4.8 s image) | 5 s (4.8 s image) |
| Run length | 74 s | 297 s |
| Waits for scanner trigger | No (starts 3 s after the instructions) | Yes (`t`) |

Each block starts with a 2 s cue ("Match emotion" or "Match shapes"); blocks
are separated by a 2 s fixation cross. Faces in a trial are the same sex.
Trial order is fixed. (The upstream wiki says shape blocks have 6 trials; the
schedule files have 5, and their total of 297 s is what runs.)

## Install

The task runs on Python 3.10 with PsychoPy 2026.2.4. The environment is
managed by [uv](https://docs.astral.sh/uv/): `pyproject.toml` lists what the
task needs, and `uv.lock` pins the exact version of every package, so every
computer runs the same tested set. The install scripts install uv if it is
missing (in `~/.local/bin`, no admin rights), run `uv sync --locked` (which
downloads uv's Python 3.10 and puts the locked packages into `.venv`), check
for the faces, and add launchers. Installing needs internet access; running
the task does not.

Supported: Linux x86-64 (tested on Ubuntu; the scanner laptop runs 22.04),
Windows x64, and Apple Silicon Macs with macOS 14 or newer. Intel Macs are not
supported (several packages have no builds for them). The macOS and Windows
parts of the scripts are untested.

**Linux / macOS:**

```bash
git clone -b linux https://github.com/ironictoo/Standard_EFMT.git
cd Standard_EFMT
./install.sh
```

- **Linux:** adds **EFMT Practice**, **EFMT Scan** and **Resting State Cross**
  to the app menu and the desktop (`.desktop` files that call `run.sh`). If libraries that the Qt
  dialogs need are missing (Ubuntu 22.04 lacks `libxcb-cursor0`), it asks
  before installing them with `sudo apt-get` (your password); answer no to
  get the command for later.
- **macOS:** adds `EFMT Practice.command`, `EFMT Scan.command` and
  `Resting State Cross.command` to the desktop.
- `./install.sh --no-launchers` skips the launchers.

**Windows** (PowerShell, in the cloned folder):

```powershell
powershell -ExecutionPolicy Bypass -File install.ps1
```

This adds **EFMT Practice**, **EFMT Scan** and **Resting State Cross**
shortcuts to the desktop.

**Updating:** `git pull`, then rerun the install script; it brings `.venv` in
line with the new `uv.lock` and adds any new launchers (such as **Resting
State Cross**). Without the script: `uv sync --locked`.

**Changing package versions** (developers): edit `pyproject.toml` or run
`uv lock --upgrade-package <name>`, then run `tools/check_wheels.sh`. It checks
that every locked package has a ready-made build for Ubuntu 22.04, macOS 14
and Windows (`uv lock` itself does not check OS versions). Test the task, and
commit `pyproject.toml` and `uv.lock` together.

**Faces.** The NimStim images are licensed, so they are not in this repo.
Request them from the Tottenham lab (https://danlab.psychology.columbia.edu/content/nimstim),
then copy the whole set (all files in one folder) to `~/NimStim/` on the
stimulus computer, or set `face_dir` in `Default.params` to where they are.
Use the original files: the task scales faces to 233×300 pixels, and file
names match regardless of upper/lower case. The task uses 32 closed-mouth
angry/fearful images (`*_AN_C`, `*_FE_C`) from actors 01F 02F 07F 11F 12F 15F
16F 18F 22M 28M 30M 36M 38M 39M 41M 45M. `.gitignore` blocks face files from
being committed.

## Settings

All in `Default.params` (one `name value` per line); `HARIRI_*.params` override
some of them for each experiment order.

| Setting | Default | Meaning |
| --- | --- | --- |
| `left`, `right`, `select` | `'a'`, `'b'`, `'c'` | Button box: button 1 (index finger) = left image, button 2 (middle finger) = right image, button 3 is logged only. Also set in each `HARIRI_*.params` |
| `trigger` | `'t'` | Key the scanner sends to start the scan run |
| `confirm_scanner_ready` | `False` | `True` adds an experimenter step before the trigger: press `z` when the scanner is ready (a trigger before `z` is ignored) |
| `screens` | `1` | `1`: one display, or the laptop cloned to the scanner screen; the task runs full screen on screen 0. `2`: task in a window on screen `screen` (size `screen_x` × `screen_y`) |
| `output_dir` | `'~/fmri_data/Standard_EFMT/'` | Local folder for output files (created if missing). Also set in each `HARIRI_*.params` |
| `face_dir` | `'~/NimStim/'` | Folder with the NimStim images |

Copy data from `output_dir` to the network drive after each session.

## Running

Use the **EFMT Practice** launcher for training (before scanning, at the
laptop), and **EFMT Scan** in the scanner. Or from the folder:

```bash
./run.sh practice
./run.sh scan
```

`run.sh` runs `.venv/bin/python StimTool.py` with the same arguments (on
Windows, run `.venv\Scripts\python.exe StimTool.py practice`). Started from
a launcher, the console output goes to
`~/.local/state/standard-efmt/launcher.log`, and if the task stops with an
error a dialog says so; run `./run.sh` in a terminal to see the output
directly.

Enter the Subject ID and your initials (Administrator ID) in the dialog. The
scan also asks for an exam number (any text; it is saved with the data).
`practice` and `scan` run the versions for a button box held in the **right**
hand; for the left hand, give the order file instead, e.g.
`StimTool.py HARIRI_ScanSession_LEFT_ButtonBox_T1.TL`. Upstream, left and right
differ only in instruction slide 2 (a picture of the button box in that hand);
here both use the same slide with our 2-button box (see below), so they run
the same.
Without an argument, `StimTool.py` asks for the experiment order; don't pick
`free`, which skips the session settings.

### Inputs

| When | Key | Effect |
| --- | --- | --- |
| Instruction slides | `b` (button 2) or `z` | Next slide |
| | `a` (button 1) | Previous slide (practice only) |
| | Backspace | Previous slide (experimenter) |
| Practice, after the instructions | none | Task starts after 3 s |
| Scan, after the instructions | `t` | Scanner trigger: task starts ("Task will begin soon" until then) |
| Trials | `a` / `b` | Left / right image; a red frame shows the choice; every press is logged and the last one counts |
| | `c` | Logged, no effect |
| "Run complete" screen | Enter | End the session |
| Any time | Escape | Stop the run, then choose OK in the dialog to rerun or Cancel to quit |

Only the keys above work (for example, not the numeric keypad). If you cancel
after Escape, StimTool switches to "free mode"; quit and restart it rather
than picking `Hariri` there (it fails with `Hariri/P` not found).

## Resting state fixation cross

For resting state fMRI, StimTool can show a fixed black cross in the centre of
a white screen. It stays up until the proctor presses **Escape**: there are no
instructions, no wait for the scanner trigger and no time limit.

1. Start it with the **Resting State Cross** launcher, or from the folder:

   ```bash
   ./run.sh rest
   ```

   (On Windows: the **Resting State Cross** shortcut, or
   `.venv\Scripts\python.exe StimTool.py rest`.)
2. Enter the Subject ID and your initials in the dialog and click OK. The
   cross appears about a second later.
3. Start the resting state sequence on the scanner.
4. When the scan has finished, press **Escape** on the laptop keyboard. The
   cross closes and StimTool quits.

Only Escape ends it; button box presses and scanner triggers are ignored. The
cross uses the same screen settings as the EFMT (`screens`, `screen_x`,
`screen_y` in `Default.params`; `RESTING_STATE_FixationCross.params` overrides
some of them). Its size is set by `CROSS_SIZE` and `CROSS_THICKNESS` (pixels)
at the top of `RestingState/RestingState.py`.

If you don't see the launcher, rerun `./install.sh` (or `install.ps1`): the
installers add it along with the EFMT launchers.

## Output

In `output_dir`, named from the Subject ID:

- `<SID>-T1-HARI-RP-_BEH.csv` (practice) or `<SID>-T1-HARI-R1-_BEH.csv` (scan):
  one row per event. `trial_type`: 0 fixation, 1 emotion cue, 2 shapes cue,
  3 emotion match, 4 shapes match. `event_code`: 2 task start (trigger), 6/7
  face/shape onset, 8 each button press, 9 final response per trial.
  `response`: 1 left, 2 right; `result`: 1 correct, 0 incorrect, -1 no
  response. Times are in seconds from the start of the instructions; the
  task (trigger) onset is event 2.
- `<SID>-T1-SCAN-RX-EXAM.txt`: the exam number (scan only).
- `<SID>-T1-REST-R1-_BEH.csv` (resting state cross): `event_code` 1 is when
  the cross appeared and 2 when Escape was pressed, with the time the cross
  was shown (seconds) in `response_time`.
- `<SID>_<date>.txt`: console log, for troubleshooting.

A second run with the same Subject ID gets `-1`, `-2`, … added instead of
overwriting. See the [upstream wiki](https://github.com/Hannah-Savage/Standard_EFMT/wiki)
for more on reading the output.

## Changes from upstream

- Runs on Linux / PsychoPy 2026.2.4: `pygame.pypm` and `pyo` imports are
  optional (instructions have no audio); audio backends `ptb`/`sounddevice`.
- Faces load from `face_dir` instead of `Hariri/media/`; upstream's
  placeholder face files are removed and `.gitignore` blocks NimStim files.
- Keys: button box `a`/`b`/`c`, trigger `t` (both settings). The
  experimenter's "previous slide" key is Backspace (it was `a`, now button 1).
  The "press `z` when the scanner is ready" step is optional and off.
- Instruction slide 2 (practice and scan) shows our button box (blue = left,
  yellow = right; photo `Hariri/media/instructions/llu_button.png`) instead
  of the stock 4-button box: `HARI_P_2_LLU.PNG` and `HARI_S_2_LLU.PNG`, used by
  all four `HARI_instruct_schedule*.csv`. `tools/button_slides.py` remakes
  them from the stock right-hand slides and the photo (for a new photo, update
  the button positions at the top of the script).
- Python environment managed by uv with a lock file (`pyproject.toml`,
  `uv.lock`); `install.sh` / `install.ps1` installers with launchers, and
  `run.sh`.
- `screens` setting for one (cloned) display; `StimTool.py practice|scan|rest`
  shortcuts; `~` allowed in folder paths.
- Resting state fixation cross (`RestingState/`, `StimTool.py rest`), with its
  own launcher.
- Fixes: the practice instructions crashed looking for a sound file named
  `' None'`; PsychoPy colour-space warning when setting the background.

Known upstream quirks: logs show "Only 2D textures are supported" for the
1×1 `blank.bmp` (harmless); each launch rewrites `last_subject`/`last_admin`
in `Default.params`.

Upstream has no license file; ask the authors before redistributing.
