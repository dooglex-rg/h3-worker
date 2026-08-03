FROM runpod/worker-comfyui:5.8.6-base

RUN pip install --upgrade comfy-cli
RUN comfy update comfy --version latest
