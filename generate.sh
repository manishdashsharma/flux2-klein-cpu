#!/usr/bin/env bash
set -euo pipefail

SD_TAG="master-945-a1ded76"
SD_REPO="leejet/stable-diffusion.cpp"
HF_REPO="manishdashsharma/flux2-klein-4b-gguf"
HF_BASE="https://huggingface.co/${HF_REPO}/resolve/main"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="${ROOT}/bin"
MODEL_DIR="${ROOT}/models"
OUT_DIR="${ROOT}/outputs"

QUANT="q4_0"
WIDTH=512
HEIGHT=512
STEPS=4
SEED=-1
OUTPUT=""
PROMPT=""

usage() {
  cat <<EOF
Usage: ./generate.sh "your prompt" [options]

Options:
  -q, --quant q4_0|q8_0   Model quality (default: q4_0, smaller and faster)
  -W, --width N           Image width, multiple of 16 (default: 512)
  -H, --height N          Image height, multiple of 16 (default: 512)
  -s, --seed N            Seed for reproducible images (default: random)
      --steps N           Sampling steps (default: 4)
  -o, --output FILE       Output path (default: outputs/<timestamp>.png)
  -h, --help              Show this help

First run downloads sd-cli and about 5 GB of models into bin/ and models/.
EOF
}

die() {
  echo "error: $*" >&2
  exit 1
}

info() {
  echo "==> $*"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -q|--quant) QUANT="$2"; shift 2 ;;
    -W|--width) WIDTH="$2"; shift 2 ;;
    -H|--height) HEIGHT="$2"; shift 2 ;;
    -s|--seed) SEED="$2"; shift 2 ;;
    --steps) STEPS="$2"; shift 2 ;;
    -o|--output) OUTPUT="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    -*) die "unknown option: $1 (see --help)" ;;
    *) [[ -z "$PROMPT" ]] || die "prompt given twice, wrap it in quotes"; PROMPT="$1"; shift ;;
  esac
done

[[ -n "$PROMPT" ]] || { usage; exit 1; }
[[ "$QUANT" == "q4_0" || "$QUANT" == "q8_0" ]] || die "quant must be q4_0 or q8_0"

for cmd in curl unzip; do
  command -v "$cmd" >/dev/null 2>&1 || die "$cmd is required"
done

OS="$(uname -s)"
ARCH="$(uname -m)"
case "${OS}-${ARCH}" in
  Darwin-arm64)
    ASSET_PATTERN="bin-Darwin-macOS-.*-arm64\.zip"
    THREADS="$(sysctl -n hw.physicalcpu)"
    ;;
  Linux-x86_64)
    ASSET_PATTERN="bin-Linux-Ubuntu-24\.04-x86_64\.zip"
    THREADS="$(nproc)"
    ;;
  *)
    die "no prebuilt sd-cli for ${OS} ${ARCH}. Build stable-diffusion.cpp from source and put sd-cli in bin/"
    ;;
esac

sha256() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | cut -d' ' -f1
  else
    shasum -a 256 "$1" | cut -d' ' -f1
  fi
}

install_sd_cli() {
  [[ -x "${BIN_DIR}/sd-cli" ]] && return
  info "Downloading sd-cli (${SD_TAG}) for ${OS} ${ARCH}"
  local api="https://api.github.com/repos/${SD_REPO}/releases/tags/${SD_TAG}"
  local url
  url="$(curl -fsSL "$api" | grep -o '"browser_download_url": *"[^"]*"' | cut -d'"' -f4 | grep -E "$ASSET_PATTERN" | head -n1)"
  [[ -n "$url" ]] || die "could not find a ${OS} ${ARCH} build in release ${SD_TAG}"
  mkdir -p "$BIN_DIR"
  local zip="${BIN_DIR}/sd.zip"
  curl -fL --progress-bar -o "$zip" "$url"
  unzip -oq "$zip" -d "$BIN_DIR"
  rm -f "$zip"
  chmod +x "${BIN_DIR}/sd-cli"
  if [[ "$OS" == "Darwin" ]]; then
    xattr -dr com.apple.quarantine "$BIN_DIR" 2>/dev/null || true
  fi
}

download_models() {
  mkdir -p "$MODEL_DIR"
  local sums="${MODEL_DIR}/SHA256SUMS.txt"
  [[ -f "$sums" ]] || curl -fsSL -o "$sums" "${HF_BASE}/SHA256SUMS.txt"
  local file expected
  for file in "flux-2-klein-4b-${QUANT}.gguf" "Qwen3-4B-Q4_K_S.gguf" "flux2-vae.safetensors"; do
    local path="${MODEL_DIR}/${file}"
    expected="$(grep " ${file}\$" "$sums" | cut -d' ' -f1)"
    [[ -n "$expected" ]] || die "${file} missing from SHA256SUMS.txt"
    if [[ ! -f "${path}.ok" ]]; then
      info "Downloading ${file}"
      curl -fL --progress-bar -C - -o "$path" "${HF_BASE}/${file}"
      info "Verifying ${file}"
      [[ "$(sha256 "$path")" == "$expected" ]] || die "checksum mismatch for ${file}, delete it and run again"
      touch "${path}.ok"
    fi
  done
}

install_sd_cli
download_models

mkdir -p "$OUT_DIR"
[[ -n "$OUTPUT" ]] || OUTPUT="${OUT_DIR}/$(date +%Y%m%d-%H%M%S).png"

info "Generating ${WIDTH}x${HEIGHT} with ${QUANT} on ${THREADS} threads"
"${BIN_DIR}/sd-cli" \
  --diffusion-model "${MODEL_DIR}/flux-2-klein-4b-${QUANT}.gguf" \
  --llm "${MODEL_DIR}/Qwen3-4B-Q4_K_S.gguf" \
  --vae "${MODEL_DIR}/flux2-vae.safetensors" \
  -p "$PROMPT" \
  --cfg-scale 1.0 --steps "$STEPS" --diffusion-fa \
  -W "$WIDTH" -H "$HEIGHT" -s "$SEED" -t "$THREADS" \
  -o "$OUTPUT"

info "Saved ${OUTPUT}"
