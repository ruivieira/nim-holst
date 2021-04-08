import unittest
import sequtils
import holst

suite "Smoke tests":
  setup:
    let java_notebook = read("./tests/notebook.ipynb")
    var nb = read("./tests/notebook.ipynb")
    nb.image_prefix = "notebook-img"
    nb.image_rel_path = "./my_images"
    nb.image_dest = "/tmp/html/my_images"

  test "Get kernel name":
    check(java_notebook.metadata.kernelspec.name == "java")

  test "Get language name":
    check(java_notebook.metadata.kernelspec.language == "java")

  test "Get display name":
    check(java_notebook.metadata.kernelspec.display_name == "Java")

  test "Get total cells":
    check(java_notebook.cells.len == 6)

  test "Get code cells":
    check(java_notebook.cells.filter(
      proc(cell: Cell): bool = cell.kind == CellKind.Code).len == 5)

  test "Get markdown cells":
    check(java_notebook.cells.filter(
      proc(cell: Cell): bool = cell.kind == CellKind.Markdown).len == 1)

  test "Default image export path and prefix":
    check(java_notebook.image_dest == "./images")
    check(java_notebook.image_prefix == "image")

  test "Set image path and prefix":
    check(nb.image_dest == "/tmp/html/my_images")
    check(nb.image_rel_path == "./my_images")
    check(nb.image_prefix == "notebook-img")
  
  test "Get image relative path":
    check(nb.build_image_rel_path(1) == "my_images/notebook-img-1.png")

  test "Get image absolute path":
    check(nb.build_image_abs_path(1) == "/tmp/html/my_images/notebook-img-1.png")

  test "Get image relative path with space":
    nb.image_prefix = "This: is the image!"
    check(nb.build_image_rel_path(1) == "my_images/This%3A+is+the+image%21-1.png")

  test "Get image absolute path with spaces":
    nb.image_prefix = "This: is the image!"
    check(nb.build_image_abs_path(1) == "/tmp/html/my_images/This%3A+is+the+image%21-1.png")
