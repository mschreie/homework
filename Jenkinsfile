pipeline {

openshift.withCluster() {
    openshift.withProject( 'dev' ) {
        echo "Hello from project ${openshift.project()} in cluster ${openshift.cluster()}"
    }
}

...

}

