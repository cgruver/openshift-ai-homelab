
```bash
mkdir -p model-image/models/OpenVINO/Qwen3-Embedding-0.6B-int8-ov/1

cat << EOF > model-image/Containerfile
FROM registry.access.redhat.com/ubi10/ubi-micro:latest
COPY --chown=0:0 models /models
RUN chmod -R a=rX /models
USER 65534
EOF

cat << EOF > model-image/models/config_all.json
{
    "model_config_list": [
        {
            "config": {
                "name": "OpenVINO/Qwen3-Embedding-0.6B-int8-ov",
                "base_path": "OpenVINO/Qwen3-Embedding-0.6B-int8-ov"
            }
        }
    ]
}
EOF

hf download OpenVINO/Qwen3-Embedding-0.6B-int8-ov --local-dir ./model-image/models/OpenVINO/Qwen3-Embedding-0.6B-int8-ov/1

podman build -t nexus.clg.lab:5002/openvino/qwen3-embedding:latest --squash-all ./model-image
podman push nexus.clg.lab:5002/openvino/qwen3-embedding:latest
```
