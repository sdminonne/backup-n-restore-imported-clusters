VIRTUALENV="./ansible2.10"
PIP=$(VIRTUALENV)/bin/pip3
ANSIBLE-GALAXY=$(VIRTUALENV)/bin/ansible-galaxy
ANSIBLE-PLAYBOOK=$(VIRTUALENV)/bin/ansible-playbook

all: venv

venv:
	LC_ALL=en_US.UTF-8 python3 -m venv $(VIRTUALENV)
	. $(VIRTUALENV)/bin/activate
	$(VIRTUALENV)/bin/python3 -m pip install --upgrade pip
	$(PIP) install ansible==2.10
	$(PIP) install -r requirements-azure.txt
	$(PIP) install kubernetes
	$(PIP) install selinux
	$(ANSIBLE-GALAXY) collection install kubernetes.core
	${PIP} install pre-commit
	${PIP} install detect-secrets

clean-venv:
	rm -fr $(VIRTUALENV)