
```bash
git clone https://github.com/ggml-org/llama.cpp.git
cd llama.cpp
cmake -B build -DGGML_CUDA=ON -DLLAMA_CURL=OFF --install-prefix /usr/local/llama-cpp
cmake --build build --config Release -j 20
sudo cmake --install build --prefix /usr/local/llama-cpp
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

```bash
cat << EOF > /etc/systemd/system/qwen3-coder-next-q6.service 
[Unit]
Description=Llama CPP Qwen3 Coder Next Q8_0 service
After=network.target

[Service]
Type=simple
LimitNOFILE=65536
ExecStart=/usr/local/llama-cpp/bin/llama-server --model /usr/local/models/Qwen3-Coder-Next-Q6_K/Qwen3-Coder-Next-Q6_K.gguf --host 0.0.0.0 --port 8080 --n-gpu-layers 999 --ctx-size 262144 --jinja  --verbose
ExecStop=kill 
User=cgruver
Restart=on-abort
Environment="LD_LIBRARY_PATH=:/usr/local/llama-cpp/lib"

[Install]
WantedBy=multi-user.target
EOF
```

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
Environment="LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/llama-cpp/lib"

[Install]
WantedBy=multi-user.target
EOF
```

```bash
systemctl daemon-reload
```
