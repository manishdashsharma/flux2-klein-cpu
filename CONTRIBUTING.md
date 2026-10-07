# Contributing

Thanks for helping make local image generation easier on CPUs.

## Ways to help

- Report a failure with the bug template, including the stable-diffusion.cpp version
- Confirm what works on other hardware (Windows, Linux, Apple Silicon, low-RAM machines)
- Improve the README or the notebook

## Development

The project is a single notebook, `notebook/notebook.ipynb`, plus a validator.

1. Fork and create a branch
2. Edit the notebook in Jupyter or Kaggle
3. Clear all outputs before committing (Kernel -> Restart and clear outputs)
4. Run `python scripts/validate_notebook.py`
5. Open a pull request using the template

## Guidelines

- Keep the notebook runnable top to bottom with Run All on a free Kaggle CPU session
- Keep every setting in the config cell
- Do not commit model weights, tokens or generated images
- Update `CHANGELOG.md` under `[Unreleased]`
- Use only public, ungated model repos when possible

By contributing you agree your work is released under the MIT License.
