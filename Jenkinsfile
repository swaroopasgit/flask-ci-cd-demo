pipeline {
    agent any

    environment {
        IMAGE_NAME = "saiswaroopa08/flask-ci-demo:latest"
        CONTAINER_NAME = "flask-ci-container"
    }

    stages {

        stage('Checkout SCM') {
            steps {
                git branch: 'main', 
                    url: 'https://github.com/swaroopasgit/flask-ci-cd-demo.git',
                    credentialsId: 'flask-ci-cd'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${IMAGE_NAME} ."
            }
        }

        stage('Docker Login & Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'Dockerhub-flask', 
                                                 usernameVariable: 'DOCKER_USERNAME', 
                                                 passwordVariable: 'DOCKER_PASSWORD')]) {
                    sh 'docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD'
                    sh "docker push ${IMAGE_NAME}"
                }
            }
        }

        stage('Deploy Container') {
            steps {
                // Stop existing container if running
                sh "docker rm -f ${CONTAINER_NAME} || true"
                // Run new container
                sh "docker run -d --name ${CONTAINER_NAME} -p 5000:5000 ${IMAGE_NAME}"
            }
        }

        stage('Smoke Test') {
            steps {
                // Simple check if container is running
                sh "docker ps | grep ${CONTAINER_NAME}"
            }
        }
    }

    post {
        always {
            echo "Cleaning up Docker container..."
            sh "docker rm -f ${CONTAINER_NAME} || true"
        }
        success {
            echo "Pipeline completed successfully!"
        }
        failure {
            echo "Pipeline failed! Check logs."
        }
    }
}
