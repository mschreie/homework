# homework
This is a quick and dirty way to automate the homework i needed to do for "Advanced OpenShift Deployment" workshop
This is very strict focusing on the "Homework" environment which i can order on the enablement Hub  / OpenTLC.

I'm using oslab.opentlc.com as my jump host.

1) Doing some stuff to get ansible up and running on "oslab.opentlc.com"
.. not automated yet

2) Doing some prep on oslab to get ansible up and working
register
subscription
install ansible

3) Getting DNS set up and ready
There is an installer to get the wildcard records set up somehow:
http://www.opentlc.com/download/ose_advanced/resources/3.1/oselab.ha.dns.installer.sh
I'Ve used that and added a second script to run my own example.com domain (as the one provides has issues, people don't fix).

dns_installer.sh <- installs dns, configures dns to serve wildcard-record
              please adjust "domain" variable to suit your needs
create_local_dns.sh <- expands the dns server to also server for example.com and it's reverse domain


NOW Ansible is working
you will always match to the "hosts" file provided in this repository
so:
ansible -i hosts all .....
or 
ansible-playbook -i hosts ....yml

4) get subscriptions on all machines 
to be automated yet

5) some additional prep
  - timezone
  - dns resolver adjustment (not there yet)
pre_deploy.yml  - predeployment


6) run OCP installation


cicd.yml
create_pv_definition.sh
hosts
htpasswd.openshift
post_deploy.yml
