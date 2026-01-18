# openshift-ai-homelab

Experiment with OpenVino Serving on Intel ARC 140T iGPU with 255H chipset

Install the following Operators -

* Cert Manager
* Node Feature Discovery
* OpenShift Serverless
* Service Mesh 3
* Intel Device Plugins
* OpenShift AI

```bash
oc apply -k 'https://github.com/intel/intel-device-plugins-for-kubernetes/deployments/nfd/overlays/node-feature-rules?ref=release-0.32'
```

```yaml
apiVersion: serving.kserve.io/v1beta1
kind: InferenceService
metadata:
  name: qwen3-8b-int4-ov
spec:
  predictor:
    model:
      runtime: kserve-openvino
      modelFormat:
        name: huggingface
      args:
        - --source_model=OpenVINO/Qwen3-8B-int4-ov
        - --model_repository_path=/tmp
        - --task=text_generation
        - --enable_prefix_caching=true
        - --tool_parser=hermes3 
        - --target_device=CPU
      resources:
        requests:
          cpu: "16"
          memory: "8G"
        limits:
          cpu: "16"
          memory: "8G"
```

```bash
curl https://raw.githubusercontent.com/openvinotoolkit/model_server/refs/heads/releases/2025/4/demos/common/export_models/export_model.py -o export_model.py
pip3 install -r https://raw.githubusercontent.com/openvinotoolkit/model_server/refs/heads/releases/2025/4/demos/common/export_models/requirements.txt
mkdir models
```

```bash
python export_model.py text_generation --source_model Qwen/Qwen3-Coder-30B-A3B-Instruct --weight-format int4 --config_file_path models/config_all.json --model_repository_path models --target_device GPU --tool_parser qwen3coder --overwrite_models
curl -L -o models/Qwen/Qwen3-Coder-30B-A3B-Instruct/chat_template.jinja https://raw.githubusercontent.com/openvinotoolkit/model_server/refs/heads/releases/2025/4/extras/chat_template_examples/chat_template_qwen3coder_instruct.jinja
```
