In this repository one can find an example of backup and restore of manually imported managed clusters.
The playbook for enabling backup assumes that the access to the HUB to backup is available while the restore playbook expect that all the managed clusters access is configured. For all cases the `kubeconfig context` is used. A strong assumption for these playbooks for manage clusters only is that the `kubeconfig context` is equal to cluster name. The playbook could be modified in case this is hypothesis is not valid.


## Setup for both backup and restore
A possible way to have access at the same time to various hub is through the `KUBECONFIG` [environment variables](https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/#linux-1) and its ability to store multiple paths. 
Assuming your kubeconfigs stays in `./kubeconfigs/<folder name>/kubeconfig`  one can write a one-liner like this one to access all the clusters in the same folder.


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

The `S3` bucket must be already created (in the ftuture we may want to create it in the `enable-backup` playbook).
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


# Configure backups


```shell
(ansible-env)$ cat var-backup.yml
HUB_CONTEXT: hub-1
```


```shell
(ansible-env)$ ansible-playbook enable-backup.yml  --vault-password-file .vault-password-file 
```

## Restore HUB


```shell
(ansible-env)$ cat vars/vars-restore.yml
HUB_CONTEXT: <your HUB to restore to context name>
```


```shell
(ansible-env)$ ansible-playbook restore-hub.yml  --vault-password-file .vault-password-file 
```
