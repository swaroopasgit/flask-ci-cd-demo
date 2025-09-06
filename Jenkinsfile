pipeline {
    agent any

    environment {
        DOCKER_USER = 'saiswaroopa08' // Your Docker Hub username
        DOCKER_PASS = credentials('docker-hub-pass') // Jenkins credential ID for Docker password
        IMAGE_NAME = 'flask-ci-demo'
        CONTAINER_NAME = 'flask-ci-container'
        HOST_PORT = '5001'
        CONTAINER_PORT = '5000'
    }

    stages {
        stage('Checkout SCM') {
            steps {
                git branch: 'main',
                    credentialsId: 'flask-ci-cd',
                    url: 'https://github.com/swaroopasgit/flask-ci-cd-demo.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Dockerfile is inside app/ folder
                    sh "docker build -t ${IMAGE_NAME}:latest -f app/Dockerfile app/"
                }
            }
        }

        stage('Docker Login & Push') {
            steps {
                script {
                    sh """
                        echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin
                        docker tag ${IMAGE_NAME}:latest \$DOCKER_USER/${IMAGE_NAME}:latest
                        docker push \$DOCKER_USER/${IMAGE_NAME}:latest
                    """
                }
            }
        }

        stage('Deploy Container') {
            steps {
                script {
                    // Stop and remove old container if exists
                    sh """
                        docker stop ${CONTAINER_NAME} || true
                        docker rm ${CONTAINER_NAME} || true
                    """

                    // Run new container
                    sh """
                        docker run -d --name ${CONTAINER_NAME} -p ${HOST_PORT}:${CONTAINER_PORT} \$DOCKER_USER/${IMAGE_NAME}:latest
                    """
                }
            }
        }

        stage('Smoke Test') {
            steps {
                script {
                    sh """
                        echo "Waiting 5 seconds for container to start..."
                        sleep 5
                        curl -f http://localhost:${HOST_PORT} || exit 1
                    """
                }
            }
        }
    }

    post {
        always {
            script {
                // Optional: cleanup container if needed
                sh "docker rm -f ${CONTAINER_NAME} || true"
            }
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed. Check the logs.'
        }
    }
}
