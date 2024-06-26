---
namespaceOverride: monitoring
prometheus:
  prometheusSpec:
    storageSpec:
     volumeClaimTemplate:
       spec:
        #  storageClassName: gluster
         accessModes: ["ReadWriteOnce"]
         resources:
           requests:
             storage: 25Gi
grafana:
  adminPassword: ${admin_password}
  ingress:
    enabled: true
    annotations:
      cert-manager.io/cluster-issuer: "letsencrypt"
      external-dns.alpha.kubernetes.io/hostname: "${grafana_fqdn}"
      kubernetes.io/ingress.class: nginx
    hosts:
    - ${grafana_fqdn}
    tls:
    - hosts:
      - ${grafana_fqdn} # This should match a DNS name in the Certificate
      secretName: tls-grafana # This should match the Certificate secretName
  additionalDataSources:
  - name: loki
    access: proxy
    basicAuth: false
    basicAuthPassword: pass
    basicAuthUser: daco
    editable: false
    jsonData:
        tlsSkipVerify: true
    orgId: 1
    type: loki
    url: http://loki-stack:3100
    version: 1
