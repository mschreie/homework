pipeline {
  agent any
    stages {
        stage('Dev: Build Tasks') {
           steps {
              openshiftBuild bldCfg: 'openshift-tasks', namespace: 'dev', showBuildLogs: 'true', verbose: 'false', waitTime: '', waitUnit: 'sec'
              openshiftVerifyBuild bldCfg: 'openshift-tasks', checkForTriggeredDeployments: 'false', namespace: 'dev', verbose: 'false', waitTime: ''
           }
        }

        stage('Dev: Tag Image') {
           steps {
              openshiftTag alias: 'false', destStream: 'openshift-tasks', destTag: '${BUILD_NUMBER}', destinationAuthToken: '', destinationNamespace: 'dev', namespace: 'dev', srcStream: 'openshift-tasks', srcTag: 'latest', verbose: 'false'
           }
        }
        stage('Dev: Deploy new image') {
           steps {
              openshiftDeploy depCfg: 'openshift-tasks', namespace: 'dev', verbose: 'false', waitTime: '', waitUnit: 'sec'
              openshiftVerifyDeployment depCfg: 'openshift-tasks', namespace: 'dev', replicaCount: '1', verbose: 'false', verifyReplicaCount: 'true', waitTime: '', waitUnit: 'sec'
              openshiftVerifyService namespace: 'dev', svcName: 'openshift-tasks', verbose: 'false', retryCount: '5'
           }
        }
        stage('acknowledge prod') {
           steps {
              timeout(time: 3, unit: 'MINUTES') {
                 input 'Ready for Prod?'
              }
           }
        }
        stage('Prod: Tag Image') {
           steps {
              openshiftTag alias: 'false', destStream: 'openshift-tasks', destTag: '${BUILD_NUMBER}', destinationAuthToken: '', destinationNamespace: 'prod', namespace: 'dev', srcStream: 'openshift-tasks', srcTag: 'latest', verbose: 'false'
           }
        }
        stage('Prod: Deploy new image') {
           steps {
              openshiftDeploy depCfg: 'openshift-tasks', namespace: 'prod', verbose: 'false', waitTime: '', waitUnit: 'sec'
              openshiftVerifyDeployment depCfg: 'openshift-tasks', namespace: 'prod', replicaCount: '1', verbose: 'false', verifyReplicaCount: 'true', waitTime: '', waitUnit: 'sec'
              openshiftVerifyService namespace: 'prod', svcName: 'openshift-tasks', verbose: 'false', retryCount: '5'
           }
        }
    }
}


