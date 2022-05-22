VIRTUALENV="./ansible-env"
PIP=$(VIRTUALENV)/bin/pip3
ANSIBLE-GALAXY=$(VIRTUALENV)/bin/ansible-galaxy
ANSIBLE-PLAYBOOK=$(VIRTUALENV)/bin/ansible-playbook

all: ansible-env

ansible-env:
	LC_ALL=en_US.UTF-8 python3 -m venv $(VIRTUALENV)
	. $(VIRTUALENV)/bin/activate
	$(VIRTUALENV)/bin/python3 -m pip install --upgrade pip
	$(PIP) install ansible==2.10
	$(PIP) install kubernetes
	$(PIP) install selinux
	$(ANSIBLE-GALAXY) collection install kubernetes.core
	${PIP} install pre-commit
	${PIP} install detect-secrets

clean-ansible-env:
	rm -fr $(VIRTUALENV)