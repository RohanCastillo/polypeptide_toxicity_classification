# Polypeptide Toxicity Classification

Binary classification of peptides as **toxic (label 1)** or **non-toxic (label 0)** from
sequence alone, comparing three feature representations: physicochemical properties,
the residue sequence itself, and protein language model embeddings.

## Results so far

| Section | Representation | Model | Accuracy | Sensitivity | Specificity | MCC |
|---|---|---|---|---|---|---|
| 2 | Residue sequence | 1D CNN | 0.9227 | 0.8187 | 0.9640 | 0.8065 |
| 1 | Physicochemical | AdaBoost | 0.9041 | 0.8125 | 0.9404 | 0.7618 |
| 1 | Physicochemical | Random Forest | 0.9005 | 0.7781 | 0.9491 | 0.7501 |
| 1 | Physicochemical | SVM | 0.8970 | 0.7625 | 0.9504 | 0.7404 |
| 3 | ProtBert | KNN | – | – | – | – |

All models are scored on the independent test set. The ProtBert KNN has not been run
yet. Every model is weaker on the toxic class: sensitivity trails specificity by 13-18
points, as expected with a 71/29 class split.

## Project structure

```
.
├── data/                             # inputs (unmodified)
│   ├── Train.fasta                   # 6,387 peptides, 4,569 non-toxic / 1,818 toxic
│   ├── test.fasta                    # 1,126 peptides, 806 non-toxic / 320 toxic
│   └── physiochemical_attributes.xlsx  # 20 amino acids x 55 properties
├── results/                          # saved run output
│   └── physiochemical_features__classifier_results.txt
├── toxicity_classification.ipynb     # the experiment: all code, in order, with commentary
├── pyproject.toml                    # dependencies, managed by uv
├── uv.lock                           # pinned versions
└── .python-version                   # 3.13
```

## Setup

Dependencies are managed with [uv](https://docs.astral.sh/uv/). To create the
environment from the lockfile:

```bash
uv sync
```

To open the notebook:

```bash
uv run jupyter lab
```

Then open `toxicity_classification.ipynb` and select the project kernel. Paths inside
the notebook are relative to the project root, so launch Jupyter from here.

To run a Python shell in the environment:

```bash
uv run python
```

### A note on torch

`pyproject.toml` pins torch to the **CPU** wheels, which are a much smaller download and
match the machine this was set up on. The notebook selects its device at runtime with
`'cuda' if torch.cuda.is_available() else 'cpu'`, so the code is correct either way — on
CPU wheels it just always reports `cpu`. To use a GPU, delete the `[tool.uv.sources]` and
`[[tool.uv.index]]` blocks at the bottom of `pyproject.toml` and run `uv sync` again.
