# homework
This is a quick and dirty way to automate the homework i needed to do for "Advanced OpenShift Deployment" workshop
This is very strict focusing on the "Homework" environment which i can order on the enablement Hub  / OpenTLC.

I'm using oslab.opentlc.com as my jump host.


1) do initial setup initiated from the notebook

Markuss-MBP:mschreie mschreie$ cd projects
Markuss-MBP:projects mschreie$ git clone https://github.com/mschreie/homework
Markuss-MBP:homework mschreie$ cd homework
Markuss-MBP:projects mschreie$ git pull

Markuss-MBP:projects mschreie$ ansible-vault create mysecrets.yml 
.... create a secrets file comparable to mysecrets.example with your crdentials

Markuss-MBP:projects mschreie$ vi 10_dns_installer.sh hosts initial_hosts files/monster2*.xml
... change Environment-ID to the correct one
... also change external_ip of infranodes in initial_hosts


Markuss-MBP:homework mschreie$ ansible-playbook -i initial_hosts --ask-vault-pass -e @mysecrets.yml -e @config.yml 00_prepare_from_notebook.yml

         Hint: If the script has issues with registering to CND, just rerun. Worked the second time for me....

     This does the following
       - adjusts timezone
       - corrects hostname (bug in lab setup)
       - subscribes hosts to Red Hat CDN
       - installs needed packages
       - yum update
       - downloads git-repository to jump-host
      
Markuss-MBP:homework mschreie$ ansible-playbook -i initial_hosts --ask-vault-pass -e @mysecrets.yml -e @config.yml 01_prepare_notebook.yml

     This does the following
       - add fqdn into local /etc/hosts to reach urls with browser from you notebook

2) do further setup initiated from jumphost in the environment

Markuss-MBP:homework mschreie$ ssh mschreie-redhat.com@oselab-8226.oslab.opentlc.com
[.....@oselab-8226 ]$ sudo -i
[root@oselab-8226 homework]# cd /root/project/homework
[root@oselab-8226 homework]# git pull
     
    This logs in to jumphost and pulls latest files from github


[root@oselab-8226 homework]# bash 10_dns_installer.sh 
     Loaded plugins: search-disabled-repos, subscription-manager
     rhel-7-fast-datapath-rpms                                                   | 4.0 kB  00:00:00     
     rhel-7-server-ansible-2.5-rpms                                              | 4.0 kB  00:00:00     
     rhel-7-server-extras-rpms                                                   | 3.4 kB  00:00:00     
     rhel-7-server-ose-3.9-rpms                                                  | 4.0 kB  00:00:00     
     rhel-7-server-rpms                                                          | 3.5 kB  00:00:00     
     (1/2): rhel-7-server-ose-3.9-rpms/x86_64/updateinfo                         |  56 kB  00:00:00     
     (2/2): rhel-7-server-ose-3.9-rpms/x86_64/primary_db                         | 286 kB  00:00:00     
     Package 32:bind-9.9.4-61.el7.x86_64 already installed and latest version
     Package 32:bind-utils-9.9.4-61.el7.x86_64 already installed and latest version
     Nothing to do
     Created symlink from /etc/systemd/system/multi-user.target.wants/named.service to /usr/lib/systemd/system/named.service.
     infraIP 1 is 35.205.82.22
     infraIP 2 is 35.205.109.218
     infraIP 3 is 35.190.200.249
     guid is 19a2
     domain is apps.19a2.oslab.opentlc.com

     test.apps.19a2.oslab.opentlc.com. 1 IN	A	35.190.200.249
     apps.19a2.oslab.opentlc.com. 1	IN	NS	master.apps.19a2.oslab.opentlc.com.

     DNS Setup was successful!
     Fully Finished the 10_dns_installer.sh script
     Loaded plugins: search-disabled-repos, subscription-manager
     Package iptables-services-1.4.21-24.el7.x86_64 already installed and latest version
     Nothing to do
     Failed to stop firewalld.service: Unit firewalld.service not loaded.
     Failed to execute operation: No such file or directory
     Created symlink from /etc/systemd/system/basic.target.wants/iptables.service to /usr/lib/systemd/system/iptables.service.
     [root@oselab-19a2 homework]# 


[root@oselab-8226 homework]# bash 11_create_local_dns.sh 
     [root@oselab-8226 homework]# 

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

[root@oselab-8226 homework]# tmux
[root@oselab-8226 homework]# tmux pipe-pane -o 'cat >>~/tmux_output.#S:#I-#P'
     This does the following
       - start tmux 
       - start tmux logging
[root@oselab-8226 homework]# ansible-playbook -i hosts /usr/share/ansible/openshift-ansible/playbooks/prerequisites.yml
[root@oselab-8226 homework]# ansible-playbook -i hosts /usr/share/ansible/openshift-ansible/playbooks/deploy_cluster.yml
    
         Hint: Both scripts take quite some time....

     This does the following
       - checks prerequisits
       - starts the deployment itself


     I ran into an "file not found: /etc/origin/logging/ca.crl.srl" issue
     and fixed that by the following:
     [root@oselab-19a2 homework]# cp files/generate_certs.yaml /usr/share/ansible/openshift-ansible/roles/openshift_logging/tasks/generate_certs.yaml    
     hint: did not automate this, as i'd suggest to check manualy...


     [root@oselab-19a2 homework]# diff -w files/generate_certs.yaml /usr/share/ansible/openshift-ansible/roles/openshift_logging/tasks/generate_certs.yaml 
     101,103c101,103
     < - name: Checking for ca.crl.srl
     <   stat: path="{{generated_certs_dir}}/ca.crl.srl"
     <   register: ca_crl_srl_file
     ---
     > - name: Checking for ca.crt.srl
     >   stat: path="{{generated_certs_dir}}/ca.crt.srl"
     >   register: ca_cert_srl_file
     106c106
     < - copy: content="" dest={{generated_certs_dir}}/ca.crl.srl
     ---
     > - copy: content="" dest={{generated_certs_dir}}/ca.crt.srl
     109c109
     <     - not ca_crl_srl_file.stat.exists
     ---
     >     - not ca_cert_srl_file.stat.exists
     [root@oselab-19a2 homework]# 

      

4) check ocp installation rudimentary

[root@oselab-8226 homework]# ssh master1.example.com
[root@master1]# oc get nodes
browse to: https://loadbalancer1-8226.oslab.opentlc.com:443/console

     This asures minimal functionality 
       - checks prerequisits
       - starts teh deployment itself


5) run post install tasks

[root@master1]# exit
[root@oselab-8226 homework]# ansible-playbook -i hosts  30_post_deploy.yml
     utilizes: create_pv_definition.sh

     This does the following
       - creat pvs (including nfs-share preparation) 
       - creates some testapp for alice



6) prepare private openshift-tasks repo
login to github.com
browse to https://github.com/wkulhanek/openshift-tasks
and fork this to your own account
i now have https://github.com/mschreie/openshift-tasks

7) install jenkins
[root@oselab-8226 homework]# ansible-playbook -i hosts  31_cicd.yml

     this script utilizes the git repo url hardcoded
     you might want to change this

8) set up jenkins ( not automated yet)

log in to  https://jenkins-jenkins.apps.1db2.oslab.opentlc.com/ as alice, bob or admin
New Item ->
Name: OpenShift-Tasks
Pipeline -> OK
Pipeline Definition:  Pipline script from SCM
SCM: Git
Repositories - Repository URL: https://github.com/mschreie/homework
-> Save

-> Build Now (press only once - should work)

at the stage "acknowledge prod" click on the box and -> proceed

To test: 
within OCP-WebUI click on dev -project and in there on the route.
A new browser tab should open the tasks application

To test: 
within OCP-WebUI click on prod -project and in there on the route.
A new browser tab should open the tasks application


9) set up HPA 
[root@oselab-8226 homework]# ansible-playbook -i hosts  32_hpa.yml

     this script enables HPA

To test: 
within OCP-WebUI click on prod -project and in there on the route.
A new browser tab should open the tasks application
within "Load GEnerator" type 100 and press load


[root@master1 ~]# oc describe hpa/openshift-tasks -n prod
     Name:                                                  openshift-tasks
     Namespace:                                             prod
     Labels:                                                <none>
     Annotations:                                           <none>
     CreationTimestamp:                                     Thu, 03 May 2018 15:09:59 +0200
     Reference:                                             DeploymentConfig/openshift-tasks
     Metrics:                                               ( current / target )
       resource cpu on pods  (as a percentage of request):  88% (44m) / 80%
     Min replicas:                                          1
     Max replicas:                                          5
     Conditions:
       Type            Status  Reason              Message
       ----            ------  ------              -------
       AbleToScale     False   BackoffBoth         the time since the previous scale is still within both the downscale and upscale forbidden windows
       ScalingActive   True    ValidMetricFound    the HPA was able to succesfully calculate a replica count from cpu resource utilization (percentage of request)
       ScalingLimited  False   DesiredWithinRange  the desired count is within the acceptable range
     Events:
       Type    Reason             Age   From                       Message
       ----    ------             ----  ----                       -------
       Normal  SuccessfulRescale  15m   horizontal-pod-autoscaler  New size: 2; reason: cpu resource utilization (percentage of request) above target
       Normal  SuccessfulRescale  9m    horizontal-pod-autoscaler  New size: 3; reason: cpu resource utilization (percentage of request) above target
       Normal  SuccessfulRescale  2m    horizontal-pod-autoscaler  New size: 4; reason: cpu resource utilization (percentage of request) above target

       .... output may look similar, you should not see errors ;-)              


#### starting Development SPIN
10)  setting up nexus and sonarqube
[root@oselab-8226 homework]# ansible-playbook -i hosts  40_developmentspin.yml

     this sets up nexus and sonarqube in seperate projects

11) prepare private ticket-master repo
XXXXXX
.. see https://keithtenzer.com/2016/08/11/openshift-v3-basic-release-deployment-scenarios/
login to github.com
browse to https://github.com/jboss-developer/ticket-monster
    alt: if it does not work: https://github.com/beelandc/ocp-appdev-ci-ticketmonster/tree/master/ticketmonster
    alt2: if it still does not work: adietish/ticket-monster
and fork this to your own account
i now have https://github.com/mschreie/openshift-tasks

12) set up jenkins for ticket-monster dev( not automated yet)

log in to  https://jenkins-jenkins.apps.1db2.oslab.opentlc.com/ as alice, bob or admin
New Item ->
Name: Monster-dev
Pipeline -> OK
Pipeline Definition:  Pipline script from SCM
SCM: Git
Repositories - Repository URL: https://github.com/mschreie/ticket-monster
Branch Specifier (blank for 'any'): */2.7.0.Final-with-tutorials
Script Path: Jenkinsfile
-> Save

-> Build Now (press only once - should work)

at the stage "acknowledge prod" click on the box and -> proceed

To test: 
within OCP-WebUI click on dev -project and in there on the route.
A new browser tab should open the tasks application

To test: 
within OCP-WebUI click on prod -project and in there on the route.
A new browser tab should open the tasks application


