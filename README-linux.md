# Running the Standard EFMT on Linux

Local `linux` branch of [Hannah-Savage/Standard_EFMT](https://github.com/Hannah-Savage/Standard_EFMT).
Upstream targets Windows and the PsychoPy3 standalone app. This branch runs it
from a Python 3.10 venv with PsychoPy 2026.2.4 on Linux.

## Setup (once)

```bash
uv venv --python 3.10 .venv
uv pip install --python .venv/bin/python -r requirements-linux.txt
```

**Faces:** NimStim images are not in git (licensed; request from the Tottenham
lab). Put the set in `NimStim/` and copy the 32 images the schedules use into
`Hariri/media/`, replacing the dummy files with the same names. Copy them with
upper-case names (a few NimStim files are lower case, e.g. `01f_an_c.BMP`).
The task scales faces to 233×300 px, so use the originals as-is.

`NimStim/` and the copied face files are excluded from git in
`.git/info/exclude`, and the tracked dummy files are marked
`git update-index --skip-worktree`, so they cannot be committed by accident.

**Site settings** are in `Default.params` and `HARIRI_*.params`:
`screen_x`/`screen_y` (participant screen, opened on screen index 1),
`output_dir`, and the response keys `left`/`right`/`select`.

## Running

```bash
.venv/bin/python StimTool.py
```

In the dialog, enter a Subject ID and Administrator ID, and pick an
Experiment Order:

| Order | What it runs |
| --- | --- |
| `HARIRI_Practice_LEFT_ButtonBox_T1.TL` | Practice, 74 s (6 face + 6 shape trials), no trigger wait |
| `HARIRI_ScanSession_LEFT_ButtonBox_T1.TL` | Scan, 297 s (24 face + 25 shape trials) |

`RIGHT` versions are for a button box in the right hand. Keys: `1` = left
image, `2` = right image, `2` (or `z`) advances instruction slides, Escape
quits.

Scan session: an Exam Number dialog appears first. After the instructions the
participant screen shows "Loading..."; press `z` when the scanner is ready,
then the task starts on `t` (the scanner trigger). Practice starts 3 s after
the instructions. At the end, press Enter on "Run complete".

## Changes from upstream

- `pygame.pypm` and `pyo` imports are optional (not needed; instructions
  have no audio). Audio backends `ptb`/`sounddevice`; ASIO drivers only on
  Windows.
- Instruction schedule fields are stripped: `HARI_instruct_scheduleP_*.csv`
  has `' None'` with a leading space, which made the practice crash looking
  for a sound file.
- `win.setColor(..., colorSpace='rgb')` to silence a PsychoPy error message.
- Params: 1920×1080 screens, Linux `output_dir`.

Known upstream quirks: shape blocks have 5 trials (the wiki says 6); the
schedules use actors 15F and 22M, which have no dummy files upstream; logs
show "Only 2D textures are supported" for the 1×1 `blank.bmp` (harmless);
each launch rewrites `last_subject`/`last_admin` in `Default.params`.
