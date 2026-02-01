# openshift-ai-homelab

Experiment with OpenVino Serving on Intel ARC 140T iGPU with 255H chipset

Install the following Operators -

* Cert Manager
* Node Feature Discovery
* OpenShift Leader Worker Set
* Red Hat Connectivity Link
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
        labelSources:
        - "local"
```

## Intel Node Feature Rules

```bash
oc apply -k 'https://github.com/intel/intel-device-plugins-for-kubernetes/deployments/nfd/overlays/node-feature-rules?ref=release-0.32' -n openshift-nfd
```

## Intel Device Plugins

```yaml
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  labels:
    operators.coreos.com/intel-device-plugins-operator.openshiftoperators: ""
  name: intel-device-plugins-operator
  namespace: openshift-operators
spec:
  channel: alpha
  installPlanApproval: Automatic
  name: intel-device-plugins-operator
  source: certified-operators
  sourceNamespace: openshift-marketplace
```

```yaml
apiVersion: deviceplugin.intel.com/v1
kind: GpuDevicePlugin
metadata:
  name: gpudeviceplugin
spec:
  image: registry.connect.redhat.com/intel/intel-gpu-plugin:0.32.1
  preferredAllocationPolicy: none
  sharedDevNum: 1
  logLevel: 4
  nodeSelector:
    intel.feature.node.kubernetes.io/gpu: "true"
```

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
apiVersion: v1
kind: Namespace
metadata:
  name: kuadrant-system
---
kind: OperatorGroup
apiVersion: operators.coreos.com/v1
metadata:
  name: kuadrant
  namespace: kuadrant-system
spec:
  upgradeStrategy: Default
---
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: rhcl-operator
  namespace: kuadrant-system
spec:
  channel: stable
  installPlanApproval: Automatic
  name: rhcl-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
```

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: openshift-lws-operator
---
kind: OperatorGroup
apiVersion: operators.coreos.com/v1
metadata:
  name: openshift-lws-operator
  namespace: openshift-lws-operator
spec:
  upgradeStrategy: Default
  targetNamespaces:
    - openshift-lws-operator
---
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: openshift-lws-operator
  namespace: openshift-lws-operator
spec:
  channel: stable-v1.0
  installPlanApproval: Automatic
  name: leader-worker-set
  source: redhat-operators
  sourceNamespace: openshift-marketplace
```

```yaml
apiVersion: datasciencecluster.opendatahub.io/v2
kind: DataScienceCluster
metadata:
  name: clg-lab-dsc
spec:
  components:
    aipipelines:
      argoWorkflowsControllers:
        managementState: Removed 
      managementState: Removed
    dashboard:
      managementState: Managed
    feastoperator:
      managementState: Removed
    kserve:
      managementState: Managed
    kueue:
      defaultClusterQueueName: default
      defaultLocalQueueName: default
      managementState: Removed
    llamastackoperator:
      managementState: Removed
    modelregistry:
      managementState: Managed
      registriesNamespace: rhoai-model-registries
    ray:
      managementState: Removed
    trainingoperator:
      managementState: Removed
    trustyai:
      managementState: Removed
    workbenches:
      managementState: Managed
      workbenchNamespace: rhods-notebooks 
```

```bash
curl https://raw.githubusercontent.com/openvinotoolkit/model_server/refs/heads/releases/2025/4/demos/common/export_models/export_model.py -o export_model.py
pip3 install -r https://raw.githubusercontent.com/openvinotoolkit/model_server/refs/heads/releases/2025/4/demos/common/export_models/requirements.txt
mkdir models
```

```bash
mkdir -p model-image/models
cat << EOF > model-image/Containerfile
FROM registry.access.redhat.com/ubi10/ubi-micro:latest
COPY --chown=0:0 models /models
RUN chmod -R a=rX /models
USER 65534
EOF
```

```bash
exportModel text_generation --source_model Qwen/Qwen3-Coder-30B-A3B-Instruct --weight-format int4 --config_file_path model-image/models/config_all.json --model_repository_path model-image/models/ --target_device GPU --tool_parser qwen3coder --overwrite_models

curl -L -o model-image/models/Qwen/Qwen3-Coder-30B-A3B-Instruct/1/chat_template.jinja https://raw.githubusercontent.com/openvinotoolkit/model_server/refs/heads/releases/2025/4/extras/chat_template_examples/chat_template_qwen3coder_instruct.jinja
```

```bash
podman build -t nexus.clg.lab:5002/openvino/qwen3-coder:latest --squash-all ./model-image
podman push nexus.clg.lab:5002/openvino/qwen3-coder:latest
```
