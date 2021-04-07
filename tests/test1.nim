import unittest
import sequtils
import holst

suite "Smoke tests":
  setup:
    let java_notebook = read("./tests/notebook.ipynb")

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
