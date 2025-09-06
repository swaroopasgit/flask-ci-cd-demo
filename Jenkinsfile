pipeline {
    agent any

    environment {
        // Docker & container settings
        IMAGE_NAME = "saiswaroopa08/flask-ci-demo"
        IMAGE_TAG = "latest"
        CONTAINER_NAME = "flask-ci-container"
        
        // Docker Hub credentials (must exist in Jenkins Credentials Manager)
        DOCKER_USER = credentials('docker-hub-user')  // your Docker Hub username
        DOCKER_PASS = credentials('docker-hub-pass')  // your Docker Hub password
    }

    stages {
        stage('Checkout Code') {
            steps {
                git(
                    url: 'https://github.com/swaroopasgit/flask-ci-cd-demo.git',
                    branch: 'main',
                    credentialsId: 'flask-ci-cd'  // Git credentials in Jenkins
                )
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
                }
            }
        }

        stage('Docker Login & Push') {
            steps {
                script {
                    sh """
                        echo ${DOCKER_PASS} | docker login -u ${DOCKER_USER} --password-stdin
                        docker push ${IMAGE_NAME}:${IMAGE_TAG}
                    """
                }
            }
        }

        stage('Deploy Container') {
            steps {
                script {
                    // Stop & remove any existing container
                    sh "docker rm -f ${CONTAINER_NAME} || true"
                    // Run new container
                    sh "docker run -d --name ${CONTAINER_NAME} -p 5001:5000 ${IMAGE_NAME}:${IMAGE_TAG}"
                }
            }
        }

        stage('Smoke Test') {
            steps {
                script {
                    sh "curl -f http://localhost:5001 || exit 1"
                }
            }
        }
    }

    post {
        always {
            script {
                // Cleanup container using env variable
                sh "docker rm -f ${env.CONTAINER_NAME} || true"
            }
        }
        success {
            echo "Pipeline completed successfully!"
        }
        failure {
            echo "Pipeline failed. Check logs."
        }
    }
}
