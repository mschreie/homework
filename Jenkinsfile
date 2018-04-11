pipeline {
    // agent { docker { image 'maven:3.3.3' } }
    stages {
        stage('build') {
           script {
              openshift.withCluster() {
                 openshift.withProject( 'dev' ) {
                    echo "Hello from project ${openshift.project()} in cluster ${openshift.cluster()}"
                 }
              }
           }
        }
    }

}
