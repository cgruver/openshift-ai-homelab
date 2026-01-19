# openshift-ai-homelab

Experiment with OpenVino Serving on Intel ARC 140T iGPU with 255H chipset

Install the following Operators -

* Cert Manager
* Node Feature Discovery
* OpenShift Serverless
* Service Mesh 3
* Intel Device Plugins
* OpenShift AI

## Cert Manager

```yaml
apiVersion: v1                      
kind: Namespace                 
metadata:
  name: cert-manager-operator
---
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: openshift-cert-manager-operator
  namespace: cert-manager-operator
spec:
  targetNamespaces:
  - cert-manager-operator
---
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: openshift-cert-manager-operator
  namespace: cert-manager-operator
spec:
  channel: stable-v1
  name: openshift-cert-manager-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
  installPlanApproval: Automatic
```

## Node Feature Discovery

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: openshift-nfd
  labels:
    name: openshift-nfd
    openshift.io/cluster-monitoring: "true"
---
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  generateName: openshift-nfd-
  name: openshift-nfd
  namespace: openshift-nfd
spec:
  targetNamespaces:
  - openshift-nfd
---
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: nfd
  namespace: openshift-nfd
spec:
  channel: "stable"
  installPlanApproval: Automatic
  name: nfd
  source: redhat-operators
  sourceNamespace: openshift-marketplace
---
```

```yaml
apiVersion: nfd.openshift.io/v1
kind: NodeFeatureDiscovery
metadata:
  name: nfd-instance
  namespace: openshift-nfd
spec:
  instance: ""
  topologyupdater: false
  operand:
    image: registry.redhat.io/openshift4/ose-node-feature-discovery-rhel9:v4.20 
    imagePullPolicy: Always
  workerConfig:
    configData: |
      core:
        sleepInterval: 60s
      sources:
        cpu:
          cpuid:
            attributeBlacklist:
              - "BMI1"
              - "BMI2"
              - "CLMUL"
              - "CMOV"
              - "CX16"
              - "ERMS"
              - "F16C"
              - "HTT"
              - "LZCNT"
              - "MMX"
              - "MMXEXT"
              - "NX"
              - "POPCNT"
              - "RDRAND"
              - "RDSEED"
              - "RDTSCP"
              - "SGX"
              - "SSE"
              - "SSE2"
              - "SSE3"
              - "SSE4.1"
              - "SSE4.2"
              - "SSSE3"
            attributeWhitelist:
        kernel:
          kconfigFile: "/path/to/kconfig"
          configOpts:
            - "NO_HZ"
            - "X86"
            - "DMI"
        pci:
          deviceClassWhitelist:
            - "0200"
            - "03"
            - "12"
          deviceLabelFields:
            - "class"
  customConfig:
    configData: |
          - name: "more.kernel.features"
            matchOn:
            - loadedKMod: ["example_kmod3"]
```

## Intel Node Feature Rules

```bash
oc apply -k 'https://github.com/intel/intel-device-plugins-for-kubernetes/deployments/nfd/overlays/node-feature-rules?ref=release-0.32'
```

## Service Mesh 3
## OpenShift Serverless
## Intel Device Plugins
## OpenShift AI

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: redhat-ods-operator 
---
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: rhods-operator
  namespace: redhat-ods-operator 
---
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: rhods-operator
  namespace: redhat-ods-operator 
spec:
  name: rhods-operator
  channel: fast-3.x
  source: redhat-operators
  sourceNamespace: openshift-marketplace 
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
