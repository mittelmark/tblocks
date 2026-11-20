# Copilot Instructions

## Project overview

`tblocks` is a Tcl package that converts a small Markdown-like document format into SVG diagrams. The implementation is concentrated in `tblocks/tblocks.tcl`; `tblocks/pkgIndex.tcl` is the Tcl package index for loading the package as `tblocks 0.1.0`.

The CLI reads the input Markdown, collects heading and body structure, dispatches by `mode`, and builds SVG strings from Tcl procedures. The main entry point is `::tblocks::main`; individual diagram implementations are namespace procedures such as `::tblocks::blocks`, `::tblocks::table`, `::tblocks::sequence`, `::tblocks::linegraph`, and `::tblocks::timeline`.

`examples/*.md` are executable format fixtures and source links for `assets/*.svg`. The `Makefile` regenerates a selected set of those assets, while `tutorial/tutorial.Rmd` and `tutorial/Makefile` build the HTML tutorial with `tmdoc` and `mndoc`.

## Build and run commands

Requires Tcl (`tclsh`). Tcl package help is available with:

```sh
tclsh tblocks/tblocks.tcl --help
tclsh tblocks/tblocks.tcl --version
```

Generate one diagram:

```sh
tclsh tblocks/tblocks.tcl --mode=sequence examples/sequence.md /tmp/sequence.svg
```

Common equivalent invocations include one input argument only (the SVG is derived by replacing the input extension) and `-` for stdin/stdout:

```sh
tclsh tblocks/tblocks.tcl examples/sequence.md
tclsh tblocks/tblocks.tcl --mode=sequence - /tmp/sequence.svg
```

PDF output is selected by naming the output `.pdf`; it creates an intermediate SVG and requires `cairosvg` or `rsvg-convert`:

```sh
tclsh tblocks/tblocks.tcl --mode=sequence examples/sequence.md /tmp/sequence.pdf
```

Font changes are CLI options:

```sh
tclsh tblocks/tblocks.tcl --mode=inout --sans-font="Alegreya Sans SC" --mono-font="Ubuntu Mono" examples/flow.md /tmp/flow.svg
```

Regenerate the Makefile's example assets:

```sh
make example
```

Build the tutorial from `tutorial/`:

```sh
make -C tutorial
```

There is no automated test suite or lint target in the repository. For a focused smoke check, generate an existing example to `/tmp` and verify the SVG is non-empty:

```sh
tclsh tblocks/tblocks.tcl --mode=sequence examples/sequence.md /tmp/tblocks-sequence.svg && test -s /tmp/tblocks-sequence.svg
```

When changing a renderer, run the relevant example and inspect the corresponding SVG (and PNG/PDF only if conversion behavior changed). `make example` updates tracked assets and is suitable for regenerating all assets covered by that target.

## Input and rendering conventions

- An optional YAML-like header is delimited by `---` at the start of the file. It may set `mode`, `sans-font`, `mono-font`, and `colorN`; an example is `examples/cpp-func-colors.md`.
- CLI `--mode=MODE` overrides are parsed by `::tblocks::pargs`; `--mode=boxes` is the CLI name for the regular block renderer. Mode names commonly used in front matter include `blocks`, `table`, `sequence`, `inout`, `inout-block`, `iblocks`, `itable`, `timeline`, `linegraph`, `flow-lr`, `ttable`, `compare`, and `toc`.
- Markdown headings start sections: `##` is the main block/node title. `###` and list lines are used by specific renderers for nested content or table-like entries; follow the nearest example for the mode being changed.
- Backticks render inline code text in modes that support code styling. Lines ending in `:` are treated as bold labels in the legacy table/sequence/inout text path.
- Palette entries are Tcl lists with separate text and background values. The main palette is initialized in `::tblocks::main`, and `colorN` front-matter or `--colorN=...` overrides replace entries.
- Icons use `icon:NAME` in headings or list items. Built-in `yes` and `no` icons are implemented in Tcl; other Material Design icons are downloaded with `wget` into an `icons/` directory relative to the current working directory and cached there.
- SVG text is emitted with Tcl string substitutions and a few explicit XML entity substitutions. Preserve existing escaping behavior in `::tblocks::text` and use the established namespace/procedure pattern when adding renderer helpers.

## Architecture and extension points

- `tblocks/tblocks.tcl` contains CLI parsing, Markdown parsing, shared SVG primitives, and every diagram renderer. Add a new mode by implementing a `::tblocks::...` renderer and wiring it into both argument/front-matter dispatch and `::tblocks::main`.
- Shared SVG output starts with `::tblocks::header`, ends with `::tblocks::footer`, and is assembled line-by-line by each mode.
- `::tblocks::main` performs the front-matter parsing, counts headings and body lines, calculates mode-specific dimensions, and dispatches to the renderer procedures.
- `pkgIndex.tcl` exposes the package version and sources `tblocks.tcl`; keep package/version declarations aligned if the package version is changed.
- Assets are generated outputs: change the source example or renderer intentionally, then regenerate and include the corresponding SVG in the change.
