# TODO: add support for k8s HPA by adding this to the EKS cluster.
# https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/
# This still needs to be thoroughly tested. It should run with the node autoscaling too.

# kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml