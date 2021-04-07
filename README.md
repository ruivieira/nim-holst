[![CI](https://github.com/ruivieira/nim-holst/actions/workflows/test.yml/badge.svg)](https://github.com/ruivieira/nim-holst/actions/workflows/test.yml) [![builds.sr.ht status](https://builds.sr.ht/~ruivieira/nim-holst/commits/.build.yml.svg)](https://builds.sr.ht/~ruivieira/nim-holst/commits/.build.yml?)

# nim-holst

![](./docs/holst.png)

A parser for Jupyter notebooks.

## setup

Add `holst` to your `nimble` project:

```nim
requires "holst"
```

and run `nimble install`

## examples

### reading

Load and parse a Jupyter notebook in `/tmp/foo.ipynb`:

```nim
import holst

let notebook = read("/tmp/foo.ipynb")
```

### metadata

Get the kernel's metadata

```nim
echo notebook.metadata.kernelspec.language # => python
echo notebook.metadata.kernelspec.name # => Python 3
```

### exporting

Export the notebook as markdown

```nim
let md = notebook.markdown()
```

Images are rendered as links in Markdown, you can export the image data to files with

```nim
notebook.export_images(path="./images", prefix="image")
```

### iterating

Apply a method to each code cell:

```nim
notebook
    .filter(proc(cell: Cell): bool = cell.kind = Cell.Code)
    .map (
        # do something
    )
```

## compatibility

`holst` works with Jupyter notebooks with format 4+.

## mailing lists

- Announcements: [https://lists.sr.ht/~ruivieira/nim-announce](https://lists.sr.ht/~ruivieira/nim-announce)
- Discussion: [https://lists.sr.ht/~ruivieira/nim-discuss](https://lists.sr.ht/~ruivieira/nim-discuss)
- Development: [https://lists.sr.ht/~ruivieira/nim-devel](https://lists.sr.ht/~ruivieira/nim-discuss)

Please prefix the subject with `[nim-holst]`.
