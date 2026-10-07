# Security Policy

## Reporting a vulnerability

Please do not open a public issue for security problems. Use GitHub's private vulnerability reporting (Security tab -> Report a vulnerability).

## Scope

The notebook downloads and builds third-party code and model files. Review `notebook/notebook.ipynb` before running it, and never paste a Hugging Face token into a cell. Store it as a Kaggle Secret named `HF_TOKEN`.
