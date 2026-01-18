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
