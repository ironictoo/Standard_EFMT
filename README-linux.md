# Running the Standard EFMT on Linux

`linux` branch of `ironictoo/Standard_EFMT`, a fork of [Hannah-Savage/Standard_EFMT](https://github.com/Hannah-Savage/Standard_EFMT).
Upstream targets Windows and the PsychoPy3 standalone app. This branch runs it
from a Python 3.10 venv with PsychoPy 2026.2.4 on Linux.

## Setup (once)

```bash
uv venv --python 3.10 .venv
uv pip install --python .venv/bin/python -r requirements-linux.txt
```

**Faces:** NimStim images are licensed (request them from the Tottenham
lab) and are never stored in this repo. The task loads face images from the
folder set by `face_dir` in `Default.params` (default
`/media/network_mriphysics/adina/NimStim/`, which must be mounted on the
stimulus computer, or point it at a local copy outside the repo). File names
match case-insensitively, and a missing folder or file stops the task with an
error. Use the original NimStim files; the task scales faces to 233x300 px.

This fork removes upstream's placeholder face files from `Hariri/media/`, and
`.gitignore` blocks `NimStim/` and any face file name in `Hariri/media/`, so
faces cannot be committed by accident.

**Site settings** are in `Default.params` and `HARIRI_*.params`:
`face_dir`, `screen_x`/`screen_y` (participant screen, opened on screen index 1),
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

`LEFT`/`RIGHT` only changes instruction slide 2 (the picture of the button
box in the left or right hand); trials and keys are identical.

Always use one of the `.TL` orders. **Free mode** (`free` in Experiment Order)
skips the `HARIRI_*.params` files, so it uses `Default.params`: the response
keys become the arrow keys and space, not `1`/`2`/`3`, it asks for the run
(schedule) in a dialog, output files get `SESSION_ID` instead of `T1`, and
console output is not saved.

## Inputs

Keys are the `left`/`right`/`select` values in the params files (button box
keys `1`/`2`/`3` with the `.TL` orders). Only the top-row number keys work,
not the numeric keypad.

| When | Input | Effect |
| --- | --- | --- |
| Start dialog | Subject ID, Administrator ID, Experiment Order | Subject ID starts the output file names |
| Scan orders only | Exam Number dialog | Required (cannot be blank); saved to `<SID>-T1-SCAN-RX-EXAM.txt` |
| Instruction slides | `2` (right) or `z` | Next slide |
| | `1` (left) or `a` | Previous slide (`1` only in practice; scan sets `allow_instructions_back False`) |
| | Escape | Stop the run |
| After instructions (practice) | none | Task starts after 3 s |
| After instructions (scan) | `z` | Experimenter: scanner ready ("Loading..." → "Task will begin soon") |
| | `t` | Scanner trigger: task starts |
| Trials | `1` / `2` | Left / right image; red frame shows the choice; every press is logged and the last one counts |
| | `3` (select) | Logged, no effect |
| | Escape | Stop the run |
| "Run complete" screen | Enter | Continue (ends the session) |
| After Escape | "File List Mode" dialog | OK reruns the task; Cancel leaves StimTool in free mode (see below) |

After Escape in a `.TL` session, cancelling that dialog drops into free mode
with the session's settings still loaded. Picking `Hariri` there crashes
(`Hariri/P` not found) because it no longer asks which run to use. To rerun,
choose OK in the File List Mode dialog, or quit and restart StimTool.

## Changes from upstream

- `pygame.pypm` and `pyo` imports are optional (not needed; instructions
  have no audio). Audio backends `ptb`/`sounddevice`; ASIO drivers only on
  Windows.
- Instruction schedule fields are stripped: `HARI_instruct_scheduleP_*.csv`
  has `' None'` with a leading space, which made the practice crash looking
  for a sound file.
- `win.setColor(..., colorSpace='rgb')` to silence a PsychoPy error message.
- Faces load from `face_dir` instead of `Hariri/media/`; placeholder
  faces removed; `.gitignore` blocks NimStim files.
- Params: 1920×1080 screens, Linux `output_dir`.

Known upstream quirks: shape blocks have 5 trials (the wiki says 6); the
schedules use actors 15F and 22M, which had no dummy files upstream; logs
show "Only 2D textures are supported" for the 1×1 `blank.bmp` (harmless);
each launch rewrites `last_subject`/`last_admin` in `Default.params`.
