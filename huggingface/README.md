---
license: apache-2.0
base_model: black-forest-labs/FLUX.2-klein-4B
base_model_relation: quantized
pipeline_tag: text-to-image
library_name: gguf
tags:
  - flux
  - flux2
  - gguf
  - quantized
  - stable-diffusion.cpp
  - cpu
---

# FLUX.2 klein 4B GGUF

Quantized GGUF files of [FLUX.2 \[klein\] 4B](https://huggingface.co/black-forest-labs/FLUX.2-klein-4B) for [stable-diffusion.cpp](https://github.com/leejet/stable-diffusion.cpp). Runs on a normal laptop without a dedicated GPU, in about 5 GB of RAM.

Guide, notebook and issues: **[github.com/manishdashsharma/flux2-klein-cpu](https://github.com/manishdashsharma/flux2-klein-cpu)**

## Files

| File | Size | Purpose |
|------|------|---------|
| `flux-2-klein-4b-q4_0.gguf` | 2.26 GB | Diffusion model, smallest and fastest |
| `flux-2-klein-4b-q8_0.gguf` | 4.17 GB | Diffusion model, closest to original quality |
| `Qwen3-4B-Q4_K_S.gguf` | 2.38 GB | Text encoder |
| `flux2-vae.safetensors` | 0.34 GB | VAE |
| `SHA256SUMS.txt` | | Checksums |

You need one diffusion model plus the text encoder and the VAE.

## Usage

```sh
hf download manishdashsharma/flux2-klein-4b-gguf \
  flux-2-klein-4b-q4_0.gguf Qwen3-4B-Q4_K_S.gguf flux2-vae.safetensors --local-dir models

./sd-cli \
  --diffusion-model models/flux-2-klein-4b-q4_0.gguf \
  --llm models/Qwen3-4B-Q4_K_S.gguf \
  --vae models/flux2-vae.safetensors \
  -p "a cat sitting on a sofa, photo" \
  --cfg-scale 1.0 --steps 4 --diffusion-fa \
  -W 512 -H 512 -o out.png
```

Get `sd-cli` from the [stable-diffusion.cpp releases](https://github.com/leejet/stable-diffusion.cpp/releases).

## Tested

| Machine | Quant | Resolution | Time | Peak RAM |
|---------|-------|------------|------|----------|
| Apple Silicon Mac, 16 GB (Metal) | q4_0 | 512x512, 4 steps | 61 s | 5.0 GB |

## How these were made

Quantized from `flux-2-klein-4b.safetensors` with `sd-cli -M convert` (stable-diffusion.cpp `master-945-a1ded76`) on a free Kaggle CPU session. The notebook is in the GitHub repo. The text encoder is `Qwen3-4B-Q4_K_S.gguf` from [unsloth/Qwen3-4B-GGUF](https://huggingface.co/unsloth/Qwen3-4B-GGUF) and the VAE is from [Comfy-Org/flux2-klein-4B](https://huggingface.co/Comfy-Org/flux2-klein-4B), both redistributed unchanged.

## License

Apache-2.0, same as the original FLUX.2 klein 4B and Qwen3-4B. All credit for the model goes to Black Forest Labs.
