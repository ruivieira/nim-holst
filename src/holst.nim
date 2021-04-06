import json
import sequtils

type KernelSpec = object
  display_name*: string
  language*: string
  name*: string

type Metadata = object
  kernelspec*: KernelSpec

type CellKind = enum
  Markdown = "markdown", Code = "code"

type Cell = object
  kind*: CellKind
  source*: seq[string]
  outputs*: seq[string]

type JupyterNotebook = object
  metadata*: Metadata
  cells*: seq[Cell]

proc read(path: string): JupyterNotebook =
  let source = readFile(path)
  let jsonNode = parseJson(source)

  let metadata_json = jsonNode["metadata"]
  let kernelspec_json = metadata_json["kernelspec"]

  let kernelspec = KernelSpec(display_name: kernelspec_json["display_name"].getStr,
                              language: kernelspec_json["language"].getStr,
                              name: kernelspec_json["name"].getStr)

  let metadata = Metadata(kernelspec: kernelspec)

  var cells = newSeq[Cell]()
  
  for cell in jsonNode["cells"]:
    let cell_type = cell["cell_type"].getStr
    let cell_source = cell["source"].elems.map(proc(x: JsonNode):string = x.getStr)
    if cell_type == "markdown":
      let c = Cell(kind: CellKind.Markdown, source: cell_source)
      cells.add(c)
    elif cell_type == "code":
      # parsing the outputs of a code cell is not simple...

      # finally create the code cell
      let c = Cell(kind: CellKind.Code, source: cell_source)
      cells.add(c)

  let notebook = JupyterNotebook(metadata: metadata,
                                 cells: cells)

  return notebook
  

when isMainModule:
  echo("hello")
  let notebook = read("./RunningCode.ipynb")

  echo notebook.metadata.kernelspec.display_name
  echo notebook.metadata.kernelspec.language
  echo notebook.metadata.kernelspec.name

  for cell in notebook.cells:
    echo(cell.kind)
    echo($cell.source)


  # for cell in jsonNode["cells"]:
  #   echo cell["cell_type"].getStr