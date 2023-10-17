# helm chart - kube-prometheus-stack

Chart source: https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack

# Known Issues

The chart will create the following AWS resources that will not be destroyed when the chart is uninstalled:

"environment_acronym-dynamic-pvc-*" volumes in EC2.  
A and TXT records in the AWS Route53 Hosted Zone (grafana.*)  

These should be manually deleted.  