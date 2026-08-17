# Upgrade OS

```bash
apt update
apt dist-upgrade
fwupdmgr refresh --force
fwupdmgr upgrade
reboot

apt install linux-headers-$(uname -r) build-essential
apt install nvidia-driver-610-open linux-modules-nvidia-610-open-nvidia-hwe-24.04 nvidia-prime-
apt autoremove
reboot
apt install cuda-toolkit-13-3
apt autoremove
```

# Notes for Llama.cpp on ASUS GX10

```bash
git clone https://github.com/ggml-org/llama.cpp.git
cd llama.cpp
cmake -B build -DGGML_CUDA=ON -DLLAMA_CURL=OFF --install-prefix /usr/local/llama-cpp
cmake --build build --config Release -j 20
sudo cmake --install build --prefix /usr/local/llama-cpp
```

### Merge GGUF files into one.

```bash
llama-gguf-split --merge Qwen3-Coder-Next-Q6_K-00001-of-00004.gguf Qwen3-Coder-Next-Q6_K.gguf
```

```bash
cat << EOF > /etc/systemd/system/qwen3-coder-next-q5.service
[Unit]
Description=Llama CPP Qwen3 Coder Next service
After=network.target

[Service]
Type=simple
LimitNOFILE=65536
ExecStart=/usr/local/llama-cpp/bin/llama-server --model /usr/local/models/Qwen3-Coder-Next/Qwen3-Coder-Next-UD-Q5_K_M.gguf --host 0.0.0.0 --port 8080 --n-gpu-layers 999 --ctx-size 262144 --jinja  --verbose
ExecStop=kill $(ps -x | grep llama-server | grep model | cut -d" " -f3)
User=cgruver
Restart=on-abort
Environment="LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/llama-cpp/lib"

[Install]
WantedBy=multi-user.target
EOF
```

## Llama.cpp Service for Qwen3-Coder-Next-Q6_K
```bash
cat << EOF > /etc/systemd/system/qwen3-coder-next-q6.service 
[Unit]
Description=Llama CPP Qwen3 Coder Next Q6_K service
After=network.target

[Service]
Type=simple
LimitNOFILE=65536
ExecStart=/usr/local/llama-cpp/bin/llama-server --model /usr/local/models/Qwen3-Coder-Next-Q6_K/Qwen3-Coder-Next-Q6_K.gguf --host 0.0.0.0 --port 8080 --n-gpu-layers 999 --ctx-size 262144 --jinja  --verbose
ExecStop=kill 
User=cgruver
Restart=on-abort
Environment="LD_LIBRARY_PATH=/usr/local/llama-cpp/lib"

[Install]
WantedBy=multi-user.target
EOF
```

## Llama.cpp Service for gpt-oss-120b-Q5_K_M

```bash
cat << EOF > /etc/systemd/system/gpt-oss.service
[Unit]
Description=Llama CPP GPT OSS service
After=network.target

[Service]
Type=simple
LimitNOFILE=65536
ExecStart=/usr/local/llama-cpp/bin/llama-server --model /usr/local/models/gpt-oss-120b-GGUF/gpt-oss-120b-Q5_K_M.gguf --host 0.0.0.0 --port 8080 --n-gpu-layers 999 --ctx-size 131072 --jinja  --verbose
ExecStop=kill $(ps -x | grep llama-server | grep model | cut -d" " -f3)
User=cgruver
Restart=on-abort
Environment="LD_LIBRARY_PATH=/usr/local/llama-cpp/lib"

[Install]
WantedBy=multi-user.target
EOF
```

## Llama.cpp Service for NVIDIA-Nemotron-3-Super-120B-A12B-UD-Q4_K_M

```bash
cat << EOF > /etc/systemd/system/nvidia-nemotron.service
[Unit]
Description=NVIDIA-Nemotron-3-Super-120B-A12B-UD-Q4_K_M
After=network.target

[Service]
Type=simple
LimitNOFILE=65536
ExecStart=/usr/local/llama-cpp/bin/llama-server --model /usr/local/models/NVIDIA-Nemotron-3-Super-120B-A12B-GGUF/NVIDIA-Nemotron-3-Super-120B-A12B-UD-Q4_K_M.gguf --host 0.0.0.0 --port 8080 --n-gpu-layers 999 --ctx-size 262144 --jinja  --verbose
ExecStop=kill 
User=cgruver
Restart=on-abort
Environment="LD_LIBRARY_PATH=/usr/local/llama-cpp/lib"

[Install]
WantedBy=multi-user.target
EOF
```

```bash
systemctl daemon-reload
```

## Notes for vLLM on DGX

```bash
apt-get install ffmpeg libavcodec-extra python3-dev ninja-build
python3 -m venv /usr/local/models/vllm
. /usr/local/models/vllm/bin/activate

pip install uv
uv pip install --upgrade vllm --torch-backend auto
```

```bash
. /usr/local/models/vllm/bin/activate

export MAX_JOBS=4

vllm serve /usr/local/models/NVIDIA-Nemotron-3-Super-120B-A12B-NVFP4 \
  --kv-cache-dtype fp8 \
  --load-format fastsafetensors \
  --gpu-memory-utilization 0.8 \
  --enable-chunked-prefill \
  --max-num-seqs 4 \
  --enable-auto-tool-choice \
  --tool-call-parser qwen3_coder \
  --reasoning-parser nemotron_v3
```

```bash
cat << EOF > /usr/local/models/vllm/vllm.env
MAX_JOBS=4
VIRTUAL_ENV=/usr/local/models/vllm
PATH=/usr/local/models/vllm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin
# VLLM_NVFP4_GEMM_BACKEND=flashinfer-b12x
# VLLM_USE_FLASHINFER_MOE_FP16=1
# VLLM_FP8_MOE_BACKEND=flashinfer_cutlass
# FLASHINFER_DISABLE_VERSION_CHECK=1
CUTE_DSL_ARCH=sm_121a
EOF
```

```bash
[Unit]
Description=NVIDIA-Nemotron-3-Super-120B-A12B-NVFP4
After=network.target

[Service]
Type=simple
LimitNOFILE=65536
ExecStart=/usr/local/models/vllm/bin/vllm serve /usr/local/models/NVIDIA-Nemotron-3-Super-120B-A12B-NVFP4 --served-model-name nemotron-3-super --kv-cache-dtype fp8 --load-format fastsafetensors --gpu-memory-utilization 0.8 --enable-chunked-prefill --enable-prefix-caching --max-num-seqs 4 --enable-auto-tool-choice --tool-call-parser qwen3_coder --reasoning-parser nemotron_v3 --max-model-len 262144 --default-chat-template-kwargs '{"force_nonempty_content": true}' --host 0.0.0.0 --port 8080 
ExecStop=kill 
User=cgruver
Restart=on-abort
EnvironmentFile=/usr/local/models/vllm/vllm.env

[Install]
WantedBy=multi-user.target
```

```
[Unit]
Description=NVIDIA-Nemotron-3-Super-120B-A12B-NVFP4
After=network.target

[Service]
Type=simple
LimitNOFILE=65536
ExecStart=/home/cgruver/.venv/bin/vllm serve /usr/local/models/NVIDIA-Nemotron-3-Super-120B-A12B-NVFP4 --served-model-name nemotron-3-super --kv-cache-dtype fp8 --load-format fastsafetensors --gpu-memory-utilization 0.8 --enable-chunked-prefill --enable-prefix-caching --max-num-seqs 4 --enable-auto-tool-choice --tool-call-parser qwen3_coder --reasoning-parser nemotron_v3 --max-model-len 262144 --default-chat-template-kwargs '{"force_nonempty_content": true}' --host 0.0.0.0 --port 8080 --speculative_config '{"method":"mtp","num_speculative_tokens":3,"moe_backend":"flashinfer_cutlass"}' --moe-backend flashinfer_b12x
ExecStop=kill 
User=cgruver
Restart=on-abort
EnvironmentFile=/usr/local/models/vllm/vllm.env

[Install]
WantedBy=multi-user.target
```

```
--moe-backend flashinfer_b12x
--enable-chunked-prefill
--max-num-batched-tokens 16384
```

## Laguna S 2.1

### July release -

```bash
[Unit]
Description=Laguna-S-2.1-NVFP4
After=network.target

[Service]
Type=simple
LimitNOFILE=65536
ExecStart=/usr/local/models/vllm/bin/vllm serve /usr/local/models/Laguna-S-2.1-NVFP4 --served-model-name laguna-S-2.1 --kv-cache-dtype fp8 --load-format fastsafetensors --gpu-memory-utilization 0.85 --enable-chunked-prefill --enable-prefix-caching --max-num-seqs 32 --enable-auto-tool-choice --trust-remote-code --tool-call-parser poolside_v1 --reasoning-parser poolside_v1 --max-model-len 262144 --default-chat-template-kwargs '{"enable_thinking": true}' --host 0.0.0.0 --port 8080 --override-generation-config '{"temperature":0.7,"top_p":0.95}' 
ExecStop=kill 
User=cgruver
Restart=on-abort
EnvironmentFile=/usr/local/models/vllm/vllm.env

[Install]
WantedBy=multi-user.target
```

### August release

```bash
hf download poolside/Laguna-S-2.1-NVFP4 --local-dir /usr/local/models/Laguna-S-2.1-NVFP4
hf download poolside/Laguna-S-2.1-DFlash-NVFP4 --local-dir /usr/local/models/Laguna-S-2.1-DFlash-NVFP4
pip install flashinfer-python 
pip install flashinfer-cubin --index-url https://flashinfer.ai/whl/
pip install flashinfer-jit-cache --index-url https://flashinfer.ai/whl/cu130/
```

```bash
export CUTE_DSL_ARCH=sm_121a          # arch string for FP4 kernel JIT
export PATH=/usr/local/cuda/bin:$PATH # nvcc for JIT
export MAX_JOBS=4                     # cap JIT fan-out; see warning below
source ~/venvs/vllm025/bin/activate

vllm serve poolside/Laguna-S-2.1-NVFP4 \
  --speculative-config '{"model":"poolside/Laguna-S-2.1-DFlash-NVFP4","num_speculative_tokens":7}' \
  --enable-auto-tool-choice \
  --tool-call-parser poolside_v1 \
  --reasoning-parser poolside_v1 \
  --max-num-seqs 32 \
  --max-model-len 262144 \
  --gpu-memory-utilization 0.85 \
  --host 0.0.0.0 --port 8000
```

```bash
cat << EOF > /usr/local/models/vllm/vllm.env
MAX_JOBS=4
VIRTUAL_ENV=/usr/local/models/vllm
PATH=/usr/local/models/vllm/bin:/usr/local/cuda/bin:/opt/bin/:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin
CUTE_DSL_ARCH=sm_121a
EOF
```

```bash
[Unit]
Description=Laguna-S-2.1-NVFP4
After=network.target

[Service]
Type=simple
LimitNOFILE=65536
ExecStart=/usr/local/models/vllm/bin/vllm serve /usr/local/models/Laguna-S-2.1-NVFP4 --host 0.0.0.0 --port 8080 --served-model-name laguna-S-2.1 --gpu-memory-utilization 0.9 --max-num-seqs 32 --enable-auto-tool-choice --tool-call-parser poolside_v1 --reasoning-parser poolside_v1 --max-model-len 262144 --speculative-config '{"model":"/usr/local/models/Laguna-S-2.1-DFlash-NVFP4","num_speculative_tokens":7}' --kv-cache-dtype fp8
ExecStop=kill 
User=cgruver
Restart=on-abort
EnvironmentFile=/usr/local/models/vllm/vllm.env

[Install]
WantedBy=multi-user.target
```