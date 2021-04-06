import json

type KernelSpec = object
  display_name*: string
  language*: string
  name*: string

type Metadata = object
  kernelspec*: KernelSpec

type JupyterNotebook = object
  metadata*: Metadata


proc read(path: string): JupyterNotebook =
  let source = readFile(path)
  let jsonNode = parseJson(source)

  let metadata_json = jsonNode["metadata"]
  let kernelspec_json = metadata_json["kernelspec"]

  let kernelspec = KernelSpec(display_name: kernelspec_json["display_name"].getStr,
                              language: kernelspec_json["language"].getStr,
                              name: kernelspec_json["name"].getStr)

  let metadata = Metadata(kernelspec: kernelspec)

  let notebook = JupyterNotebook(metadata: metadata)

  return notebook
  

when isMainModule:
  echo("hello")
  let notebook = read("./RunningCode.ipynb")

  echo notebook.metadata.kernelspec.display_name
  echo notebook.metadata.kernelspec.language
  echo notebook.metadata.kernelspec.name


  # for cell in jsonNode["cells"]:
  #   echo cell["cell_type"].getStr