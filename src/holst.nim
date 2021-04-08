import json
import sequtils
import options
from strutils import join
import strformat
import base64
import os

type KernelSpec* = object
  ## This type contains a description of a kernel specification
  display_name*: string
  language*: string
  name*: string

type Metadata* = object
  ## This type contains the notebook's metadata
  kernelspec*: KernelSpec

type CellKind* = enum
  ## Cell type enumeration
  Markdown = "markdown", Code = "code"

type Cell* = object
  ## This type contains cell's data
  kind*: CellKind
  source*: seq[string]
  outputs*: seq[string]
  image_data*: Option[string]
  text_data*: Option[string]
  stdout*: Option[seq[string]]

proc has_image_output*(cell: Cell): bool =
  return cell.image_data.isSome

proc has_text_output*(cell: Cell): bool =
  return cell.text_data.isSome

proc has_stdout_output*(cell: Cell): bool =
  return cell.stdout.isSome


type JupyterNotebook* = object
  ## This type contains the notebook's data
  metadata*: Metadata
  cells*: seq[Cell]
  image_dest*: string
  image_prefix*: string

proc build_image_path*(notebook: JupyterNotebook, image_counter: int): string =
  joinPath(notebook.image_dest, fmt"{notebook.image_prefix}-{image_counter}.png" )


proc markdown*(notebook: JupyterNotebook): string =
  var image_counter = 1
  var contents = ""
  for cell in notebook.cells:
    if cell.kind == CellKind.Markdown:
      contents &= cell.source.join() & "\n"
      contents &= "\n"
    elif cell.kind == CellKind.Code:
      contents &= "```\n"
      contents &= cell.source.join() & "\n"
      contents &= "```\n"
      if cell.has_image_output():
        contents &= "\n"
        let image_path = notebook.build_image_path(image_counter)
        contents &= fmt"![image-{image_counter}]({image_path})" & "\n"
        contents &= "\n"
        image_counter += 1
      if cell.has_stdout_output():
        contents &= "```\n"
        contents &= cell.stdout.get.join() & "\n"
        contents &= "```\n"


  return contents


proc export_images*(notebook: JupyterNotebook) =
  var image_counter = 1
  if not dirExists(notebook.image_dest):
    createDir(notebook.image_dest)
  for cell in notebook.cells:
    if cell.has_image_output():
      let image_data = decode(cell.image_data.get)
      let image_path = notebook.build_image_path(image_counter)
      writeFile(image_path, image_data)
      image_counter += 1

proc read*(path: string): JupyterNotebook =
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
    var text_data = none(string)
    var stdout = none(seq[string])
    let cell_type = cell["cell_type"].getStr
    let cell_source = cell["source"].elems.map(proc(
        x: JsonNode): string = x.getStr)
    if cell_type == "markdown":
      let c = Cell(kind: CellKind.Markdown, source: cell_source)
      cells.add(c)
    elif cell_type == "code":
      # parsing the outputs of a code cell is not simple...
      ## check if any of the output items has a key called "data"
      let outputs = cell["outputs"]
      let data = outputs.elems.filter(proc(
          output: JsonNode): bool = output.hasKey("data")).map(proc(
          x: JsonNode): JsonNode = x["data"])
      if data.len > 0:
        let images = data.filter(proc(x: JsonNode): bool = x.hasKey("image/png"))
        if images.len > 0:
          image_data = some(images[0]["image/png"].getStr)
        let text = data.filter(proc(x: JsonNode): bool = x.hasKey("text/plain"))
        if text.len > 0:
          text_data = some(text[0]["text/plain"].getStr)
      let named_output = outputs.elems.filter(proc(
          output: JsonNode): bool = output.hasKey("name") and output[
          "name"].getStr == "stdout")
      if named_output.len > 0:
        stdout = some(named_output[0]["text"].elems.map(proc(
            x: JsonNode): string = x.getStr))

      # finally create the code cell
      let c = Cell(kind: CellKind.Code, source: cell_source,
          image_data: image_data, text_data: text_data, stdout: stdout)
      cells.add(c)

  let notebook = JupyterNotebook(metadata: metadata,
                                 cells: cells,
                                 image_dest: "./images",
                                 image_prefix: "image")

  return notebook
