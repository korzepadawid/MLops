pipeline {
    agent any
    stages {
        stage('Git Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Train') {
            steps {
                script {
                    def mlopsImage = docker.build('mlops')
                    mlopsImage.inside {
                        sh 'python3 ./model.py'
                        archiveArtifacts artifacts: 'ner_model/**/*.*', onlyIfSuccessful: true
                    }
                }
            }
        }
    }
}
