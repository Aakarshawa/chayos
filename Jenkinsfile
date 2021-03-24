pipeline {
  agent none

  stages{
         stage('Checkout'){
			agent {
				label 'JavaAgent'
			}
			steps{					
				stage('Checkout') {
              git url: 'git@github.com:Aakarshawa/chayos.git', credentialsId: 'chayos', branch: 'master'
            }
			}
		}
         stage('Build'){
			agent {
				label 'JavaAgent'
			}
			steps{
				script{
                    sh 'mvn clean install'
		    def pom = readMavenPom file:'complete/pom.xml'
		    print pom.version
	            env.version = pom.version
				}					
			}
		}
		stage('Image Build'){
		    agent {
				label 'JavaAgent'
			}
			steps{
          	   script{
                     sh "docker build -t rest-service:${env.version}"
                     sh " docker tag rest-service:${env.version} Aakarshawa/rest-service:${env.version}"
                   }	
			}
		}
		stage('Push Docker Image''){
		    agent {
				label 'JavaAgent'
			}
			steps{
			  script{
			    sh "docker push rest-service:${env.version}"
				}
              }				
		}
		stage ('Deployment') {
		    agent {
				label 'JavaAgent'
			}
			steps{
			  script{
			    echo "DEPLOY APPLICATION WITH IMAGE ${env.version} ....."
				sh "deploy/deployment.sh"
				}
              }	
		
		 
}
