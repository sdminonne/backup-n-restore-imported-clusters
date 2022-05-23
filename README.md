In this repository one can find an example of backup and restore of manually imported managed clusters.


## Setup

Assuming your kubeconfigs stays in `./kubeconfigs` folder

```shell
$ unset KUBECONFIG
$ for item in $(find kubeconfigs -name kubeconfig); do if [ -z ${KUBECONFIG+x} ]; then export KUBECONFIG=$(pwd)/${item}; else export KUBECONFIG=${KUBECONFIG}:$(pwd)/$item; fi; done
$ $ kubectl config get-contexts
CURRENT   NAME                         CLUSTER                      AUTHINFO                                                    NAMESPACE
          dario-managed-1-public-aks   dario-managed-1-public-aks   clusterUser_dario-managed-1-rg_dario-managed-1-public-aks   
          dario-managed-2-public-aks   dario-managed-2-public-aks   clusterUser_dario-managed-2-rg_dario-managed-2-public-aks   
*         hub-1                        hub-1-backup-imported        admin                                                       
          hub-2                        hub-2-backup-imported        admin 
```





# Configure backups

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
HUB_CONTEXT: hub-1

BUCKET: imported-clusters-test-bucket
STORAGE_REGION: us-east-1
```


```shell
(ansible-env)<YOUR_USUAL_PROMPT>$  ansible-vault edit vault/aws.yml
```

```shell
(ansible-env)<YOUR_USUAL_PROMPT>$ echo "YOUR VAULT PASSWORD" > .vault-password-file
``

```
(ansible-env)<YOUR_USUAL_PROMPT>$  ansible-vault view vault/aws.yml --vault-password-file .vault-password-fie 
AWS_ACCESS_KEY: <Your aws acces key>
AWS_SECRET_ACCESS_KEY: <Your aws secret key here>
```



```shell
(ansible-env)<YOUR_USUAL_PROMPT>$ ansible-playbook enable-backup.yml  --vault-password-file .vault-password-file 
```


## Restore HUB


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
HUB_CONTEXT: hub-2

BUCKET: imported-clusters-test-bucket
STORAGE_REGION: us-east-1
```


```shell
(ansible-env)<YOUR_USUAL_PROMPT>$ ansible-playbook restore-hub.yml  --vault-password-file .vault-password-file 
```
