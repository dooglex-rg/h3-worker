FROM runpod/worker-comfyui:fix-network-volume-model-paths-base

RUN cd /comfyui && \
    if [ "$(git rev-parse --is-shallow-repository)" = "true" ]; then git fetch --unshallow origin; else git fetch origin; fi && \
    git reset --hard origin/HEAD && \
    pip install --upgrade -r requirements.txt

COPY extra_model_paths.yaml /comfyui/extra_model_paths.yaml
