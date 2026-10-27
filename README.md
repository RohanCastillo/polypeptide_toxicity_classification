# Polypeptide Toxicity Classification

Machine learning project for the group of Rohan, Lasaro, and Don.

Binary classification of peptides as **toxic (label 1)** or **non-toxic (label 0)** from
sequence alone, comparing three feature representations: physicochemical properties,
the residue sequence itself, and protein language model embeddings.

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

### Run Section 1 on Amarel

Section 1 uses CPUs only; keep the existing CPU torch configuration. The runner
executes Setup and Section 1 directly from the notebook, stopping before Section 2.
It performs 2,185 cross-validation fits plus three final refits. The batch script
requests eight CPUs, 32 GB RAM, and 24 hours as an initial allocation; actual runtime
and memory requirements have not yet been measured on Amarel.

From your local project directory, replace `YOUR_NETID` and transfer the project,
including the three input files in `data/`:

```bash
rsync -av --progress --exclude='.git/' --exclude='.venv/' \
  --exclude='.env*' --exclude='.aws/' --exclude='.ssh/' \
  --exclude='.codex/' --exclude='.agents/' --exclude='__pycache__/' \
  --exclude='.ruff_cache/' --exclude='.ipynb_checkpoints/' \
  README.md pyproject.toml uv.lock .python-version .gitignore \
  toxicity_classification.ipynb run_section1.py section1.sbatch data \
  YOUR_NETID@amarel.rutgers.edu:~/polypeptide_toxicity_classification/
```

On Amarel, with `uv` available on your PATH, prepare the environment once and submit
from the project root. `uv sync --frozen` installs the existing locked dependencies;
the compute job uses that environment without downloading packages.

```bash
cd ~/polypeptide_toxicity_classification
uv sync --frozen
mkdir -p results
sbatch section1.sbatch
squeue -u "$USER"
```

Use the job ID printed by `sbatch` to follow its output:

```bash
tail -f results/section1-JOB_ID.log
```

The log contains best hyperparameters, cross-validation MCC, and test confusion
matrices, accuracy, sensitivity, specificity, and MCC for all three classifiers.
Look for `Section 1 complete.` to confirm the runner finished. Output can be quiet
during grid search. Existing results below are historical, not a fresh Amarel run;
the older file's `CV Score` values should not be treated as current CV MCC results.

To retrieve the new logs, run this from the local project directory:

```bash
rsync -av --progress \
  'YOUR_NETID@amarel.rutgers.edu:~/polypeptide_toxicity_classification/results/section1-*.log' \
  results/
```

Data and private `.env` files are excluded from Git. Transfer the course data
separately with the command above when setting up another checkout.

### A note on torch

`pyproject.toml` pins torch to the **CPU** wheels, which are a much smaller download and
match the machine this was set up on. The notebook selects its device at runtime with
`'cuda' if torch.cuda.is_available() else 'cpu'`, so the code is correct either way — on
CPU wheels it just always reports `cpu`. To use a GPU, delete the `[tool.uv.sources]` and
`[[tool.uv.index]]` blocks at the bottom of `pyproject.toml` and run `uv sync` again.

## Results so far

| Section | Representation | Model | Accuracy | Sensitivity | Specificity | MCC |
|---|---|---|---|---|---|---|
| 2 | Residue sequence | 1D CNN | 0.9227 | 0.8187 | 0.9640 | 0.8065 |
| 1 | Physicochemical | AdaBoost | 0.9041 | 0.8125 | 0.9404 | 0.7618 |
| 1 | Physicochemical | Random Forest | 0.9005 | 0.7781 | 0.9491 | 0.7501 |
| 1 | Physicochemical | SVM | 0.8970 | 0.7625 | 0.9504 | 0.7404 |
| 3 | ProtBert | KNN | – | – | – | – |

Section 4 of the notebook discusses these. Two things to be aware of when reading them:
the PLM section currently evaluates on an 80/20 split of the training data rather than
the independent test set, so its numbers are not directly comparable; and every model is
noticeably weaker on the toxic class than the non-toxic one.
