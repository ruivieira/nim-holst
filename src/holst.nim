import json
import sequtils
import options

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
  image_data*: Option[string]

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
    var image_data = none(string)
    let cell_type = cell["cell_type"].getStr
    let cell_source = cell["source"].elems.map(proc(x: JsonNode):string = x.getStr)
    if cell_type == "markdown":
      let c = Cell(kind: CellKind.Markdown, source: cell_source)
      cells.add(c)
    elif cell_type == "code":
      # parsing the outputs of a code cell is not simple...
      ## check if any of the output items has a key called "data"
      let outputs = cell["outputs"]
      let data = outputs.elems.filter(proc(output: JsonNode):bool = output.hasKey("data")).map(proc(x:JsonNode):JsonNode = x["data"])
      if data.len > 0:
        let images = data.filter(proc(x: JsonNode): bool = x.hasKey("image/png"))
        if images.len > 0:
        # if images.len >0:
          image_data = some(images[0]["image/png"].getStr)

      # finally create the code cell
      let c = Cell(kind: CellKind.Code, source: cell_source, image_data: image_data)
      cells.add(c)

  let notebook = JupyterNotebook(metadata: metadata,
                                 cells: cells)

  return notebook 
  

when isMainModule:
  echo("hello")
  let notebook = read("./SVM.ipynb")

  echo notebook.metadata.kernelspec.display_name
  echo notebook.metadata.kernelspec.language
  echo notebook.metadata.kernelspec.name

  for cell in notebook.cells:
    # echo(cell.kind)
    # echo($cell.source)
    echo(cell.image_data)


  # for cell in jsonNode["cells"]:
  #   echo cell["cell_type"].getStr