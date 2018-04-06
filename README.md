# homework
This is a quick and dirty way to automate the homework i needed to do for "Advanced OpenShift Deployment" workshop
This is very strict focusing on the "Homework" environment which i can order on the enablement Hub  / OpenTLC.

I'm using oslab.opentlc.com as my jump host.


1) do initial setup initiated from the notebook

Markuss-MBP:mschreie mschreie$ cd projects
Markuss-MBP:projects mschreie$ git clone https://github.com/mschreie/homework
Markuss-MBP:homework mschreie$ cd homework
Markuss-MBP:projects mschreie$ git pull

Markuss-MBP:homework mschreie$ ansible-playbook -i initial_hosts --ask-vault-pass -e @mysecrets.yml -e @config.yml 00_prepare_from_notebook.yml

         Hint: If the script has issues with registering to CND, just rerun. Worked the second time for me....

     This does the following
       - adjusts timezone
       - corrects hostname (bug in lab setup)
       - subscribes hosts to Red Hat CDN
       - installs needed packages
       - yum update
       - downloads git-repository to jump-host
      
2) do further setup initiated from jumphost in the environment

Markuss-MBP:homework mschreie$ ssh mschreie-redhat.com@oselab-8226.oslab.opentlc.com
[root@oselab-8226 homework]# sudo -i; cd /root/project/homework
[root@oselab-8226 homework]# git pull
     
    This logs in to jumphost and pulls latest files from github


[root@oselab-8226 homework]# 10_dns_installer.sh 
[root@oselab-8226 homework]# 11_create_local_dns.sh 

    There is an installer to get the wildcard records set up somehow:
    http://www.opentlc.com/download/ose_advanced/resources/3.1/oselab.ha.dns.installer.sh
    I've used that and added a second script to run my own example.com domain (as the one provides has issues, people don't fix).

    10_dns_installer.sh <- installs dns, configures dns to serve wildcard-record
              please adjust "domain" variable to suit your needs
             be carefull rerunning this, as it is quite destructive, you will want the second dns-script to run as well
    11_create_local_dns.sh <- expands the dns server to also server for example.com and it's reverse domain


[root@oselab-8226 homework]# ansible-playbook -i hosts 12_pre_deploy.yml 

         Hint: Now using "hosts" file, which is the official hosts file also for OCP install. It differs from initial_hosts, which was used from noteboook

     This does the following
       - adjusts resolv.conf on all hosts


[root@oselab-8226 homework]# ansible all -i hosts -m shell -a "cat /etc/sysconfig/docker-storage"

      On my systems docker storage was configured to utilize a thin pool, i did not need to adjust this myself...

      Output of the cmd looks similar to:
      node5.example.com | SUCCESS | rc=0 >>
      DOCKER_STORAGE_OPTIONS=--storage-driver devicemapper --storage-opt dm.fs=xfs --storage-opt dm.thinpooldev=/dev/mapper/docker--vg-docker--pool

3) do ocp installation

[root@oselab-8226 homework]#  tmux
[root@oselab-8226 homework]# tmux pipe-pane -o 'cat >>~/tmux_output.#S:#I-#P'
     This does the following
       - start tmux 
       - start tmux logging
[root@oselab-8226 homework]# ansible-playbook -i hosts /usr/share/ansible/openshift-ansible/playbooks/prerequisites.yml
[root@oselab-8226 homework]# ansible-playbook -i hosts /usr/share/ansible/openshift-ansible/playbooks/deploy_cluster.yml

    
         Hint: Both scripts take quite some time....

     This does the following
       - checks prerequisits
       - starts teh deployment itself

4) check ocp installation rudimentary

[root@oselab-8226 homework]# oc get nodes
browse to: https://loadbalancer1-8226.oslab.opentlc.com:8443/console

     This asures minimal functionality 
       - checks prerequisits
       - starts teh deployment itself


5) run post install tasks

[root@oselab-8226 homework]# ansible-playbook -i hosts  30_post_deploy.yml
     utilizes: create_pv_definition.sh

     This does the following
       - creat pvs (including nfs-share preparation) 
       - creates some testapp for alice




8) set up jenkins
[root@oselab-8226 homework]# ansible-playbook -i hosts  31_cicd.yml


Needed for the scripts to run:
hosts   
    this is the standar OCP configuration file -i do not add any parameters here, bus utilize this file as a base for the self created scripts as well.
htpasswd.openshift
    three users are defined (admin, alice, bob); admin wil be promoted to cluster-admim during with one of the playbooks...

