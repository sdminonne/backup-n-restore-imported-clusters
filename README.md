In this repository one can find an example of backup and restore of manually imported managed clusters for RHACM. More specifically there are two playbooks:
1. `enable-backup.yml` to enable the backups of the HUB
2. `restore-hub.yml` to restore the HUB configuration in another Openshift cluster.

The playbook for enabling backup assumes that the access to the HUB to backup is available. 
 Instead the restore playbook expects that the HUB is accessible and all the managed clusters are configured. For both (HUB and managed clusters) the `kubeconfig context` is used, hence the restore playbook launches the command similar to `kubectl --context=<CONTEXT NAME>`. Note that this is a strong assumption for these playbooks for managed clusters only is that the `kubeconfig context` is equal to cluster name. The playbook could be modified in case this is hypothesis is not valid.


## Setup for both backup and restore
A possible way to have access at the same time to various hub is through the `KUBECONFIG` [environment variables](https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/#linux-1) and its ability to store multiple paths. 
Assuming your kubeconfigs stays in `./kubeconfigs/<folder name>/kubeconfig`  one can write a one-liner like this one to access all the clusters in the same folder.

```shell
$ unset KUBECONFIG
$ for item in $(find kubeconfigs -name kubeconfig); do if [ -z ${KUBECONFIG+x} ]; then export KUBECONFIG=$(pwd)/${item}; else export KUBECONFIG=${KUBECONFIG}:$(pwd)/$item; fi; done
```

So the kubeconfig are available and could be listed in the usual way.

```shell
$ oc config get-contexts
CURRENT   NAME       CLUSTER                AUTHINFO       NAMESPACE 
*         hub-1      hub-1-backup-imported  admin
          managed-1  managed-1               managed-1-user
[...]
```

The python virtual environment with the proper dependencies is installed through the `Makefile`.


```shell
$ make ansible-env
LC_ALL=en_US.UTF-8 python3 -m venv "./ansible-env"
[... skipped for brevity ...]
$
$ source ansible-env/bin/activate
(ansible-env)$
```

## Importing managed cluster

Since restoring a manually imported managed cluster task is very similar to import a managed cluster, this set of ansible roles supply a way to import a cluster.

```shell
(ansible-env)$ cat vars-hub.yml
HUB_CONTEXT: hub-1
```

```shell
(ansible-env)$ oc config get-contexts
CURRENT   NAME        CLUSTER                 AUTHINFO    NAMESPACE
*         hub-1       hub-1-backup-imported   admin       
          managed-1   managed-1               managed-1   default
          managed-2   managed-2               managed-2   default
```

```shell
(ansible-env)$ ansible-playbook import-cluster.yml -e MANAGED_CLUSTER_NAME=managed-1
[.... skipped for brevrity ... ] 
(ansible-env)$ ansible-playbook import-cluster.yml -e MANAGED_CLUSTER_NAME=managed-2
[.... skipped for brevrity ... ] 
```

After the commands above your clusters should be imported and available

```shell
(ansible-env)$ oc get managedclusters
NAME            HUB ACCEPTED   MANAGED CLUSTER URLS                                               JOINED   AVAILABLE   AGE
local-cluster   true           https://api.hub-1-the-cluster-name.this-an.exmaple.com:6443        True     True        3d1h
managed-1       true                                                                              True     True        51m
managed-2       true                                                                              True     True        6m52s
```


# Configure backups

```shell
(ansible-env)$ cat vars-hub.yml
HUB_CONTEXT: hub-1
```

The `S3` bucket will be created in case it's not already. 
Obviously the `S3` must be the same for both `backup` and `restore`. the `vars/var-s3.yml` should contain the `bucket` and `region`.


```shell
(ansible-env)$ cat vars/var-s3.yml
BUCKET: <your s3 bucket>
STORAGE_REGION: <your region>
```

The `S3` credentials should stay in the `ansible vault`. This approach is obviulsy simplistic and it should not be used in the production but at least it makes difficult to commit in git the `AWS` credentials.

```shell
(ansible-env)$  ansible-vault edit vault/aws.yml
```

```shell
(ansible-env)$ echo "unbreakable vault password" > .vault-password-file
```

```shell
(ansible-env)$  ansible-vault view vault/aws.yml --vault-password-file .vault-password-fie 
AWS_ACCESS_KEY: <Your aws acces key>
AWS_SECRET_ACCESS_KEY: <Your aws secret key here>
```


```shell
(ansible-env)$ cat var-backup.yml
HUB_CONTEXT: hub-1
```


```shell
(ansible-env)$ ansible-playbook enable-backup.yml  --vault-password-file .vault-password-file 
```

## Restore HUB

```shell
(ansible-env)$ cat vars-hub.yml
HUB_CONTEXT: hub-1
```

The `S3` bucket must be already present and it should contain the backups.
The `vars/var-s3.yml` should contain the `bucket` and `region`.


```shell
(ansible-env)$ cat vars/var-s3.yml
BUCKET: <your s3 bucket>
STORAGE_REGION: <your region>
```

The `S3` credentials should stay in the `ansible vault`. This approach is obviulsy simplistic and it should not be used in the production but at least it makes difficult to commit in git the `AWS` credentials.

```shell
(ansible-env)$  ansible-vault edit vault/aws.yml
```

```shell
(ansible-env)$ echo "unbreakable vault password" > .vault-password-file
```

```shell
(ansible-env)$  ansible-vault view vault/aws.yml --vault-password-file .vault-password-fie 
AWS_ACCESS_KEY: <Your aws acces key>
AWS_SECRET_ACCESS_KEY: <Your aws secret key here>
```


```shell
(ansible-env)$ cat vars/vars-restore.yml
HUB_CONTEXT: <your HUB to restore to context name>
```


```shell
(ansible-env)$ ansible-playbook restore-hub.yml  --vault-password-file .vault-password-file 
```
