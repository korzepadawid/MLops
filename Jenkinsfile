pipeline {
    agent any
    stages {
        stage('Git Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    def mlopsImage = docker.build('mlops')
                }
            }
        }
        stage('Train') {
            steps {
                script {
                    docker.image('mlops').inside {
                        sh 'python3 ./model.py'
                        archiveArtifacts artifacts: 'ner_model/**/*.*', onlyIfSuccessful: true
                    }
                }
            }
        }
    }
}
