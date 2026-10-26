# Polypeptide Toxicity Classification

Machine learning project for the group of Rohan, Lasaro, and Don.

Binary classification of peptides as **toxic (label 1)** or **non-toxic (label 0)** from
sequence alone, comparing three feature representations: physicochemical properties,
sequence-based composition and bigrams, and protein language model embeddings.

## Project structure

```
.
├── data/                             # inputs (unmodified)
│   ├── Train.fasta                   # 6,387 peptides, 4,569 non-toxic / 1,818 toxic
│   ├── test.fasta                    # 1,126 peptides, 806 non-toxic / 320 toxic
│   └── physiochemical_attributes.xlsx  # 20 amino acids x 55 properties
├── results/                          # saved run output
│   ├── physiochemical_features__classifier_results.txt
│   ├── sequenceBasedFeaturesOUTPUT.txt
│   └── sequenceBasedFeaturesOUTPUTCNN.png
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
| 2 | Bigram matrix | CNN | 0.92 | – | – | 0.7998 |
| 1 | Physicochemical | AdaBoost | 0.9041 | 0.8125 | 0.9404 | 0.7618 |
| 1 | Physicochemical | Random Forest | 0.9005 | 0.7781 | 0.9491 | 0.7501 |
| 1 | Physicochemical | SVM | 0.8970 | 0.7625 | 0.9504 | 0.7404 |
| 2 | Occurrence + AAC | AdaBoost | 0.8037 | 0.5688 | 0.8970 | 0.4952 |
| 3 | ProtBert | KNN | – | – | – | – |

Section 4 of the notebook discusses these. Two things to be aware of when reading them:
the PLM section currently evaluates on an 80/20 split of the training data rather than
the independent test set, so its numbers are not directly comparable; and every model is
noticeably weaker on the toxic class than the non-toxic one.

---

## Assignment specification

Project Outline:
  1. You are provided with two text files in the group project module, namely train and test.
     In these files, each record consists of 2 lines (the first line starts with “>”) as shown below:

        - >peptide|1
        - EITVEPVRHPKKDPSEAE

     The first line consists of “>peptide” followed by “|” and after that “0” or “1”. Peptides demonstrate the
     nature of the input that is presented in the next line. The number after the “|” is the label. Label “1”
     represents “toxic peptides” and label “0” represents non-toxic peptides. The following line is the
     corresponding peptide sequence.

2. You need to get protein sequences and extract relevant features that are representative of
    the protein sequences. You can also use the features that are already available. You are
    required to extract three different groups of features:


    2.1 Physicochemical-based features: These are extracted based on the physical, chemical, and
    physicochemical properties of proteins, peptides, and amino acids. You can get more information on how
    to extract these features from the following articles. You need to use the numerical values of these
    features for amino acids and then extract the corresponding feature group. You can extract them directly
    or use the tools that are introduced in the following papers. More information can also be found in the
    papers that are provided in the project-related module (they will also be introduced throughout the
    course and lectures). More information can be found in:
      - Ferdous_etal_2024
      - Muhammod_etal_2019
      - Chen_etal_2018

    2.2 Sequence-based features: These features are extracted based on the alphabetic sequence of
    peptides. To extract such features, we just rely on the ordering as well as the combination of alphabets
    (relying on statistical as well as mathematical models for feature extraction regardless of physicochemical
    property and nature of amino acids). Examples of such features are amino acid composition, occurrence,
    and bi-gram. More information can be found in:
    - Ferdous_etal_2024
    - Muhammod_etal_2019
    - Chen_etal_2018

    2.3 Protein encoding using Protein Language Models (PLMs): PLMs are Large Language Models (LLMs)
    that are trained on large protein databases and generate corresponding numerical encoding of proteins.
    Such encoding can be used as input features for different machine learning models.

    (More information on what PLM is and several different PLMs that you can use is provided in
    “Protein_Language_Model” that is provided in the “Project” module.
    You can use any of these PLMs (whichever you find more interesting, informative, or easier to use).

3. You will need to prepare the data (properly put them together with labels) and use different
machine learning methods on them (e.g., K-Nearest Neighbor (KNN), Support Vector Machine
(SVM), Naïve Bayes, Artificial Neural Network (ANN), Random Forest, Bagging). As the data
suggest, the problem is hand is a multi-class classification task.

    - You are required to use at least one deep learning architecture (e.g., Convolutional Neural Network
    (CNN), which is suitable when the input data is in matrix format). More information can be found in
    “Azim_etal_2023” in the group project module.

4. You then need to analyze and interpret your output using different approaches, such as:
    - 3.1: Using an independent test set (provided in the group project module)
    - 3.2: k-fold cross-validation
    - 3.3: check different accuracy measurements (e.g., accuracy, sensitivity, specificity, Matthews
    Correlation Coefficient (MCC))
    - 3.4: Discuss your results and interpret the output (analyze the results with respect to the features
    and classifiers to demonstrate each one's effectiveness and importance (every single feature
    group and classifier being used)).

**Note: You need to do your project in the Python programming language (except the CCIB student that
can also use the R programming language).**

As the output: You will prepare a report (in Word or text document) that explains what you did in each
and every step in detail and presents your results, analysis, and discussion (no more than 6 pages). You
will also send your code with proper comments along with your report.
