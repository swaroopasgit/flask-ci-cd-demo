pipeline {
    agent any

    environment {
        CONTAINER_NAME = 'flask-ci-container'
        IMAGE_NAME = 'saiswaroopa08/flask-ci-demo'
        DOCKERHUB_CRED = 'docker-hub-creds' // Jenkins credentials ID for Docker Hub
        GIT_CRED = 'flask-ci-cd'            // Jenkins credentials ID for Git
    }

    stages {
        stage('Checkout SCM') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/swaroopasgit/flask-ci-cd-demo.git',
                    credentialsId: "${GIT_CRED}"
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${IMAGE_NAME}:latest ."
            }
        }

        stage('Docker Login & Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: "${DOCKERHUB_CRED}", 
                                                 passwordVariable: 'DOCKER_PASS', 
                                                 usernameVariable: 'DOCKER_USER')]) {
                    sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
                    sh "docker push ${IMAGE_NAME}:latest"
                }
            }
        }

        stage('Deploy Container') {
            steps {
                sh "docker rm -f ${CONTAINER_NAME} || true"
                sh "docker run -d --name ${CONTAINER_NAME} -p 5001:5000 ${IMAGE_NAME}:latest"
            }
        }

        stage('Smoke Test') {
            steps {
                sh "sleep 5"
                sh "curl -f http://localhost:5001 || exit 1"
            }
        }
    }

    post {
        always {
            echo 'Cleaning up Docker container...'
            sh "docker rm -f ${CONTAINER_NAME} || true"
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed! Check logs.'
        }
    }
}
