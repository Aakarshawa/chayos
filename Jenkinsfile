pipeline {
  agent any
  stages {
          stage('Checkout') {
              git url: 'git@github.com:Aakarshawa/Assignment_chayos.git', credentialsId: 'chayos', branch: 'master'
          }

          stage('Build') {
              sh 'mvn clean install'
              def pom = readMavenPom file:'complete/pom.xml'
              print pom.version
              env.version = pom.version
          }

          stage('Image') {
              dir ('rest-service') {
                  def app = docker.build "rest-service:${env.version}"
                  app.push()
              }
          }

          stage ('Push Docker Image') {
          sh "docker push rest-service:${env.version}"
          }

          stage ('Deployment') {
              echo "DEPLOY APPLICATION WITH IMAGE ${env.version} ....."
              sh "deploy/deployment.sh"
          }
  }
}
