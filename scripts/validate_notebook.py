import ast
import json
import sys
from pathlib import Path

NOTEBOOK = Path(__file__).resolve().parent.parent / "notebook" / "notebook.ipynb"


def validate(path: Path) -> list[str]:
    errors: list[str] = []
    notebook = json.loads(path.read_text(encoding="utf-8"))

    if notebook.get("nbformat") != 4:
        errors.append("nbformat must be 4")

    for index, cell in enumerate(notebook["cells"]):
        if cell["cell_type"] != "code":
            continue
        if cell.get("outputs"):
            errors.append(f"cell {index}: outputs must be cleared")
        if cell.get("execution_count") is not None:
            errors.append(f"cell {index}: execution_count must be null")
        source = "".join(cell["source"])
        if source.lstrip().startswith("%%"):
            continue
        try:
            ast.parse(source)
        except SyntaxError as exc:
            errors.append(f"cell {index}: syntax error: {exc}")

    return errors


def main() -> int:
    errors = validate(NOTEBOOK)
    for error in errors:
        print(error, file=sys.stderr)
    if errors:
        return 1
    print("notebook ok")
    return 0


if __name__ == "__main__":
    sys.exit(main())
