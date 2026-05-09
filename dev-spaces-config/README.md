
```bash
oc login -u=admin $(oc whoami --show-server)

oc delete configmap kilo-code-config -n devspaces
oc create configmap kilo-code-config --from-file=kilo.jsonc -n devspaces
oc label configmap kilo-code-config app.kubernetes.io/part-of=che.eclipse.org app.kubernetes.io/component=workspaces-config -n devspaces
oc annotate configmap kilo-code-config controller.devfile.io/mount-as=subpath controller.devfile.io/mount-path=/projects/.globalconfig -n devspaces

oc create configmap roo-code-config --from-file=roo-code-settings.json --from-file=opencode.json -n devspaces
oc label configmap roo-code-config app.kubernetes.io/part-of=che.eclipse.org app.kubernetes.io/component=workspaces-config -n devspaces
oc annotate configmap roo-code-config controller.devfile.io/mount-as=subpath controller.devfile.io/mount-path=/projects/.globalconfig -n devspaces
```