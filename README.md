# Spizz Neue

Source and build pipeline for the Spizz Neue typeface.

## Layout

```
sources/SpizzNeue.glyphspackage   Glyphs source (one file per glyph)
sources/config.yaml        gftools builder config
proof/index.html           Browser proofing page
fonts/                     Build output, not committed
  variable/                Variable TTF
  ttf/  otf/               Static instances
  webfonts/                WOFF2
out/fontbakery/            QA report
```

## Setup

Needs Python 3.10 or newer (macOS ships 3.9):

```bash
brew install python@3.12
```

The first `make build` creates `venv/` and installs everything in `requirements.txt`.

## Commands

| Command      | What it does                                                   |
|--------------|----------------------------------------------------------------|
| `make build` | Builds variable, static and web fonts into `fonts/`            |
| `make test`  | Runs Fontbakery (universal profile), report in `out/fontbakery/report.html` |
| `make proof` | Builds, then serves the proof page at http://localhost:8000/proof/ |
| `make clean` | Deletes build output                                           |

## Glyphs source notes

- The source is `SpizzNeue.glyphspackage` (or change `sources:` in `sources/config.yaml`).
- Define masters along a Weight axis and add an instance for each static weight you want.
  Static fonts are generated from those instances.
- If the variable font has more axes than `wght`, update the `@font-face` URL in
  `proof/index.html` to match the generated file name (for example `SpizzNeue[wdth,wght].woff2`).

## CI

`.github/workflows/build.yml` builds and runs Fontbakery on every push and pull request.
The built fonts and the QA report are uploaded as a workflow artifact.
The build step is skipped until a Glyphs source is committed.

## Releasing

1. In Glyphs, set the version in Font Info → Font → Version (for example 0.1) and save.
2. Commit, then tag and push:

   ```bash
   git tag v0.1
   git push origin v0.1
   ```

CI builds the fonts and publishes a GitHub Release with `SpizzNeue-v0.1.zip`.
Tags starting with `v0` are marked as pre-releases.
