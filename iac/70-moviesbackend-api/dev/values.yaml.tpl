# Default values for standard-application.

#
# ReplicaCount denotes how many pods you want
#
replicaCount: 1

nameOverride: ""
fullnameOverride: "${fullnameoverride}"

namespace: "${namespace}"

labels: 
  app: ${app}

#
# Deployment variables
#
deployment:
  #
  # deployment spec template annotations
  #
  annotations: {}
    # prometheus.io/path: /stats/prometheus
    # prometheus.io/port: "15020"
    # prometheus.io/scrape: "true"
    # sidecar.istio.io/status: '{"initContainers":["istio-init"],"containers":["istio-proxy"],"volumes":["istio-envoy","istio-data","istio-podinfo","istio-token","istiod-ca-cert"],"imagePullSecrets":null}'
  #
  # Enable initContainers definition
  #
  enableInitContainer: false
  initContainers:
  - name: init-container-name
    image: docker.io/my-container:foo
    # any other init container usage spec: https://kubernetes.io/docs/concepts/workloads/pods/init-containers/#init-containers-in-use
    # This usage is different than the below "containers" section.  This section will directly output the following yaml list into
    # the following location in the deployment spec: "spec.template.spec.initContainers".
  #
  # containers definition
  #
  containers:
  - name: ${container_name}
    image:
      repository: ${repository}
      tag: ${tag}
      pullPolicy: Always
    command: []
    # - foo
    # - bar
    args: []
    # - foo2
    # - bar2

    env:
      # Values in the base environment will be applied across all environments, and are NOT expected to be overridden
      # on a per-environment basis
      base: []
      # - name: foo
      #   value: bar

      # Values in perEnv will be local to an environment
      perEnv:
       - name: DATABASECONNECTION
         value: mysql://burntdvds:BuRnTdVdS8902348.ovusoiud@${mysql_rw_cluster}/burntdvds
       - name: CONFIGENV
         value: ${configenv}
       - name: WORKERS
         value: "${workers}"
       - name: WEBSERVPORT
         value: "${container_port}"

    ports:
     - name: https
       protocol: TCP
       containerPort: ${container_port}
       servicePort: 443

    livenessProbe: {}
      # httpGet:
      #   path: /
      #   port: http
    readinessProbe: {}
      # httpGet:
      #   path: /
      #   port: http
    resources:
      # We usually recommend not to specify default resources and to leave this as a conscious
      # choice for the user. This also increases chances charts run on environments with little
      # resources, such as Minikube. If you do want to specify resources, uncomment the following
      # lines, adjust them as necessary, and remove the curly braces after 'resources:'.
       limits:
        cpu: 1500m
        memory: 128Mi
       requests:
        cpu: 500m
        memory: 64Mi

    securityContext: {}
      # allowPrivilegeEscalation: false
      # capabilities:
      #   drop:
      #   - ALL
      # privileged: false
      # readOnlyRootFilesystem: true
      # runAsGroup: 1337
      # runAsNonRoot: true
      # runAsUser: 1337

    volumeMounts: []
    # # name must match the volume name below
    # - name: secret-volume
    #   mountPath: /etc/secret-volume

  imagePullSecrets: []
  # - registry-secret-1
  # - registry-secret-2

  strategy: {}
    # type: Recreate
    # rollingUpdate:
    #   maxSurge: 1
    #   maxUnavailable: 1

  containerSpecOptions: {}
    # dnsPolicy: ClusterFirst
    # restartPolicy: Always
    # schedulerName: default-scheduler
    # terminationGracePeriodSeconds: 30

  nodeSelector: {}

  tolerations: []

  affinity: {}

#
# Volumes - to be attached to the pod.
#
# This only attaches the volume to the pod.  To use it, you have to add a "volumeMounts" to
# a container on the location to mount it to or add it the content to the "env" of a container
# in the pod.
#
volumes: []
# - name: secret-volume
#   secret:
#     secretName: test-secret
# - name: config-volume
#   configMap:
#     # Provide the name of the ConfigMap containing the files you want
#     # to add to the container
#     name: special-config

#
# Service Monitors variables
#
servicemonitor:
  enabled: false

#
# Service variables
#
service:
  type: ClusterIP
  port: ${container_port}

#
# Ingress variables
#
ingress:
  enabled: true
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt"
    external-dns.alpha.kubernetes.io/hostname: ${api_fqdn}
    kubernetes.io/ingress.class: nginx
    kubernetes.io/api: app/v1
  paths: 
    - path: /
      servicePort: ${container_port}
  hosts:
    - ${api_fqdn}
  tls:
    - hosts:
        - ${api_fqdn}
      secretName: ${tls_name}

#
# HPA
#
hpa:
  enabled: false
  spec:
    scaleTargetRef:
      apiVersion: apps/v1
      kind: Deployment
      name: standard-application
    minReplicas: 1
    maxReplicas: 10
    targetCPUUtilizationPercentage: 50
