# Changelog

All notable changes are documented here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added
- Published quantized files on Hugging Face: manishdashsharma/flux2-klein-4b-gguf
- Hugging Face model card, sample image and tested results (Apple Silicon, q4_0)

### Changed
- README download section now points to the project's own Hugging Face repo

## [0.1.0] - 2026-10-08

### Added
- Kaggle notebook that quantizes FLUX.2 klein 4B to GGUF with stable-diffusion.cpp
- Download of the Qwen3-4B text encoder and the FLUX.2 VAE
- GGUF header verification, `SHA256SUMS.txt` and a zipped bundle
- Optional upload of the bundle to a Hugging Face repo
- Notebook validation script and GitHub Actions workflow
