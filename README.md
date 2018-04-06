# homework
This is a quick and dirty way to automate the homework i needed to do for "Advanced OpenShift Deployment" workshop
This is very strict focusing on the "Homework" environment which i can order on the enablement Hub  / OpenTLC.

I'm using oslab.opentlc.com as my jump host.

1) Doing some stuff to get ansible up and running on "oslab.opentlc.com"
and
2) Doing some prep on other hosts to

Markuss-MBP:homework mschreie$ ansible-playbook -i initial_hosts --ask-vault-pass -e @mysecrets.yml -e @config.yml 00_prepare_from_notebook.yml

Hint: If the script has issues with registering to CND, just rerun. Worked the second time for me....



3) Getting DNS set up and ready
There is an installer to get the wildcard records set up somehow:
http://www.opentlc.com/download/ose_advanced/resources/3.1/oselab.ha.dns.installer.sh
I've used that and added a second script to run my own example.com domain (as the one provides has issues, people don't fix).

10_dns_installer.sh <- installs dns, configures dns to serve wildcard-record
              please adjust "domain" variable to suit your needs
             be carefull rerunning this, as it is quite destructive, you will want the second dns-script to run as well
11_create_local_dns.sh <- expands the dns server to also server for example.com and it's reverse domain

[root@oselab-86ca ocp_homework]# 10_dns_installer.sh 
[root@oselab-86ca ocp_homework]# 11_create_local_dns.sh 

4) NOW Ansible is working
you will always match to the "hosts" file provided in this repository
so:
ansible -i hosts all .....
or 
ansible-playbook -i hosts ....yml

## 5) get subscriptions on all machines 
## to be automated yet

6) some additional preparation
  - timezone
  - dns resolver adjustment - please adjust IP-Adresses in the pre_deploy.yml script
pre_deploy.yml 

[root@oselab-86ca ocp_homework]# ansible-playbook -i hosts pre_deploy.yml 

6) run OCP installation
start tmux 
[root@oselab-86ca ocp_homework]#  tmux
start tmux logging
[root@oselab-86ca ocp_homework]# tmux pipe-pane -o 'cat >>~/tmux_output.#S:#I-#P'
call the ocp deployment
[root@oselab-86ca ocp_homework]# ansible-playbook -i hosts /usr/share/ansible/openshift-ansible/playbooks/byo/config.yml 


7) run post install tasks
  - creat pvs (including nfs-share preparation) 
  - creates some testapp for alice
[root@oselab-86ca ocp_homework]# ansible-playbook -i hosts  post_deploy.yml
     utilizes: create_pv_definition.sh

8) set up jenkins
[root@oselab-86ca ocp_homework]# ansible-playbook -i hosts  cicd.yml


Needed for the scripts to run:
hosts   
    this is the standar OCP configuration file -i do not add any parameters here, bus utilize this file as a base for the self created scripts as well.
htpasswd.openshift
    three users are defined (admin, alice, bob); admin wil be promoted to cluster-admim during with one of the playbooks...


