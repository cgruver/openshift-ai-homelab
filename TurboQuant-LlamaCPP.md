# Experiments with https://github.com/TheTom/turboquant_plus

Notes -

```bash
llama-server --model ./models/devstral:24b --host 0.0.0.0 --n-gpu-layers 999 --flash-attn --ctx-size 131072 --jinja --no-prefill-assistant --verbose --reasoning-format none

hf download Qwen/Qwen3-Coder-Next-GGUF Qwen3-Coder-Next-Q5_K_M/Qwen3-Coder-Next-Q5_K_M-00001-of-00004.gguf --local-dir /usr/local/models

llama-server --model /usr/local/models/Qwen3-Coder-Next-Q5_K_M/Qwen3-Coder-Next-Q5_K_M-00001-of-00004.gguf --host 0.0.0.0 --n-gpu-layers 999 --ctx-size 262144 --jinja

/Users/cgruver/llama-cpp-turboquant/build/bin/llama-server --model /usr/local/models/qwen3-coder:30b --host 0.0.0.0 --port 8080 --n-gpu-layers 999 --flash-attn on --ctx-size 262144 --jinja --no-prefill-assistant --reasoning-format none --cache-type-k turbo3 --cache-type-v turbo3 
```