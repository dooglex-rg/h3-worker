# Base: RunPod's fix branch for the network-volume model-path detection bug
# (stock worker-comfyui failed to see models/diffusion_models and
# models/text_encoders when sourced from a network volume)
FROM runpod/worker-comfyui:fix-network-volume-model-paths-base

# Triton JIT-compiles custom quantization kernels (int8_convrot, etc.) at
# runtime and needs a real C compiler + Python headers to do it.
RUN apt-get update && \
    apt-get install -y --no-install-recommends build-essential python3-dev && \
    rm -rf /var/lib/apt/lists/*

# Bump ComfyUI core to the latest commit — MiniMax H3's native nodes require
# 0.30.0+, and comfy-cli's own `update --version` flag isn't in any released
# PyPI build yet, so we do it directly via git instead.
RUN cd /comfyui && \
    if [ "$(git rev-parse --is-shallow-repository)" = "true" ]; then git fetch --unshallow origin; else git fetch origin; fi && \
    git reset --hard origin/HEAD && \
    pip install --upgrade -r requirements.txt

# Belt-and-suspenders fix for the network-volume model path bug — tells
# ComfyUI directly where to find diffusion_models/text_encoders/vae on the
# volume, regardless of whether the base image's own auto-detection works.
COPY extra_model_paths.yaml /comfyui/extra_model_paths.yaml

# Force everything to stay resident in VRAM instead of dynamically paging
# weights to/from CPU RAM throughout generation — unnecessary overhead on a
# GPU with enough VRAM headroom (confirmed via aimdo logs showing repeated
# multi-GB swap cycles during a run that had 20GB+ free the whole time).
RUN sed -i 's|main.py --disable-auto-launch|main.py --disable-auto-launch --gpu-only|g' /start.sh
