pipeline {
  agent any
    stages {
        stage('build') {
           steps {
              script {
                 openshift.withCluster() {
                    openshift.withProject( 'dev' ) {
                       echo "Hello from project ${openshift.project()} in cluster ${openshift.cluster()}"
                    }
                 }
              }
              script {
                 openshift.withCluster() {
                    openshift.withProject( 'dev' ) {
                       openshift.newApp('jboss-eap70-openshift:1.6~https://github.com/wkulhanek/openshift-tasks')
                    }
                 }
              }
           }
        }
    }

}

