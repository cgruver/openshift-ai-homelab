# Start with fresh DGX OS install

```bash
systemctl set-default multi-user.target
apt update
apt dist-upgrade
fwupdmgr refresh --force
fwupdmgr upgrade
reboot

apt install linux-headers-$(uname -r) build-essential python3-dev nvidia-driver-615-open linux-modules-nvidia-615-open-nvidia-hwe-24.04 nvidia-prime- cuda-toolkit-13-3
apt autoremove
reboot
```

```bash
groupadd vllm
useradd -g vllm vllm
```

```bash
mkdir -p /usr/local/models
python3 -m venv /usr/local/models/vllm
. /usr/local/models/vllm/bin/activate
pip install uv
uv pip install --upgrade vllm --torch-backend auto
pip install flashinfer-python 
# pip install flashinfer-cubin --index-url https://flashinfer.ai/whl/
pip install flashinfer-cubin==0.7.0.post1 --index-url https://flashinfer.ai/whl/
# pip install flashinfer-jit-cache --index-url https://flashinfer.ai/whl/cu130/
pip install flashinfer-jit-cache==0.7.0.post1+cu130 --index-url https://flashinfer.ai/whl/cu130/ 
pip install runai-model-streamer

hf download poolside/Laguna-S-2.1-NVFP4 --local-dir /usr/local/models/Laguna-S-2.1-NVFP4
hf download poolside/Laguna-S-2.1-DFlash-NVFP4 --local-dir /usr/local/models/Laguna-S-2.1-DFlash-NVFP4

cat << EOF > /usr/local/models/vllm/vllm.env
MAX_JOBS=4
VIRTUAL_ENV=/usr/local/models/vllm
PATH=/usr/local/models/vllm/bin:/usr/local/cuda/bin:/opt/bin/:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin
CUTE_DSL_ARCH=sm_121a
VLLM_CACHE_ROOT=/usr/local/models/.cache/vllm
TRITON_CACHE_DIR=/usr/local/models/.cache/triton
TORCHINDUCTOR_CACHE_DIR=/usr/local/models/.cache/torch
Environment="VLLM_ENABLE_STARTUP_PLAN=1"
EOF

chown -R vllm:vllm /usr/local/models
```

```bash
cat << EOF > /etc/systemd/system/laguna.service
[Unit]
Description=Laguna-S-2.1-NVFP4
After=network.target

[Service]
Type=simple
LimitNOFILE=65536
ExecStart=/usr/local/models/vllm/bin/vllm serve /usr/local/models/Laguna-S-2.1-NVFP4 --host 0.0.0.0 --port 8080 --served-model-name laguna-S-2.1 --gpu-memory-utilization 0.95 --max-num-seqs 32 --enable-auto-tool-choice --tool-call-parser poolside_v1 --reasoning-parser poolside_v1 --max-model-len 262144 --speculative-config '{"model":"/usr/local/models/Laguna-S-2.1-DFlash-NVFP4","num_speculative_tokens":7}' --kv-cache-dtype fp8 --load-format runai_streamer --model-loader-extra-config '{"concurrency": 8}'
ExecStop=kill 
User=vllm
Restart=on-abort
EnvironmentFile=/usr/local/models/vllm/vllm.env

[Install]
WantedBy=multi-user.target
EOF
```