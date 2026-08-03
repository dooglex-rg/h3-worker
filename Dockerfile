FROM runpod/worker-comfyui:5.8.6-base

RUN cd /comfyui && \
    if [ "$(git rev-parse --is-shallow-repository)" = "true" ]; then git fetch --unshallow origin; else git fetch origin; fi && \
    git reset --hard origin/HEAD && \
    pip install --upgrade -r requirements.txt
