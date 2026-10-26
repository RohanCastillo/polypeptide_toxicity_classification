"""Run the notebook setup and Section 1 from the project root."""

import json
from pathlib import Path


def main() -> None:
    """Execute the existing notebook code up to Section 2."""
    notebook = json.loads(Path("toxicity_classification.ipynb").read_text())
    namespace = {"__name__": "__main__"}
    for index, cell in enumerate(notebook["cells"]):
        source = "".join(cell["source"])
        if cell["cell_type"] == "markdown" and any(
            line.startswith("## 2.") for line in source.splitlines()
        ):
            break
        if cell["cell_type"] == "code":
            print(f"Running notebook cell {index}", flush=True)
            exec(compile(source, f"notebook-cell-{index}", "exec"), namespace)
    print("Section 1 complete.", flush=True)


if __name__ == "__main__":
    main()
