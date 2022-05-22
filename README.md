In this repository one can find an example of backup and restore of manually imported managed clusters.


## Setup

Assuming your kubeconfigs stays in `./kubeconfigs` folder

```shell
$ unset KUBECONFIG
$  for item in $(find kubeconfigs -name kubeconfig); do if [ -z ${KUBECONFIG+x} ]; then export KUBECONFIG=${item}; else export KUBECONFIG=${KUBECONFIG}:$item; fi; done
$ $ kubectl config get-contexts
CURRENT   NAME                         CLUSTER                      AUTHINFO                                                    NAMESPACE
*         admin                        hub-1-backup-imported        admin
          dario-managed-1-public-aks   dario-managed-1-public-aks   clusterUser_dario-managed-1-rg_dario-managed-1-public-aks
          dario-managed-2-public-aks   dario-managed-2-public-aks   clusterUser_dario-managed-2-rg_dario-managed-2-public-aks

```


```shell
$ make ansible-env
LC_ALL=en_US.UTF-8 python3 -m venv "./ansible-env"
[... skipped for brevity ...]
$
$ source ansible-env/bin/activate
(ansible-env)$
```


```shell
(ansible-env)<YOUR_USUAL_PROMPT>$ cat var.yml
HUB_CTRX: hub-1
```

# Configure backups


```shell
(ansible-env)<YOUR_USUAL_PROMPT>$ ansible-playbook enable-backup.yml -e "@var.yml"
```
