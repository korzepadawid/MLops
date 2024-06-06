pipeline {
    agent any
    stages {
        stage('Git Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Load data') {
            steps {
                script {
                    def mlopsImage = docker.build('mlops')
                    mlopsImage.inside {
                        sh 'python3 ./load_data.py'
                    }
                }
            }
        }
        stage('Train') {
            steps {
                script {
                    def customImage = docker.build('custom-image')
                    customImage.inside {
                        sh '/app/.venv/bin/python ./model.py'
                        archiveArtifacts artifacts: 'ner_model/**/*', onlyIfSuccessful: true
                    }
                }
            }
        }
    }
}
