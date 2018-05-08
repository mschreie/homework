node {
   stage 'Checkout'
   git branch: '2.7.0.Final', url: 'https://github.com/mschreie/ticket-monster.git'
   
   // ** NOTE: This 'M3' maven tool must be configured in the global configuration.
   def mvnHome = tool 'M3'
   
   stage 'Build'
   sh "${mvnHome}/bin/mvn -f demo/pom.xml clean install"
   
   stage 'Deploy to dev'
   def builder = new com.openshift.jenkins.plugins.pipeline.OpenShiftBuilder("", "ticket-monster", "ticket-monster-dev", "", "", "", "", "true", "", "")
   step builder
}

