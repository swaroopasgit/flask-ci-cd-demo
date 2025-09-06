pipeline {
    agent any

    environment {
        IMAGE_NAME = 'saiswaroopa08/flask-ci-demo:latest'
        CONTAINER_NAME = 'flask-ci-container'
    }

    stages {
        stage('Checkout SCM') {
            steps {
                git branch: 'main', credentialsId: 'flask-ci-cd', url: 'https://github.com/swaroopasgit/flask-ci-cd-demo.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${IMAGE_NAME} ."
            }
        }

        stage('Docker Login & Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'Dockerhub-flask', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
                    sh "docker push ${IMAGE_NAME}"
                }
            }
        }

        stage('Deploy Container') {
            steps {
                script {
                    // Stop and remove previous container if it exists
                    sh "docker rm -f ${CONTAINER_NAME} || true"

                    // Find an available port starting from 5000
                    def hostPort = 5000
                    while (sh(script: "lsof -i :${hostPort}", returnStatus: true) == 0) {
                        hostPort += 1
                    }

                    // Run container
                    sh "docker run -d --name ${CONTAINER_NAME} -p ${hostPort}:5000 ${IMAGE_NAME}"
                    echo "Container running on host port ${hostPort}"
                }
            }
        }

        stage('Smoke Test') {
            steps {
                script {
                    def testStatus = sh(script: "curl -s -o /dev/null -w '%{http_code}' http://localhost:5000", returnStdout: true).trim()
                    if (testStatus != '200') {
                        error "Smoke test failed! Status code: ${testStatus}"
                    } else {
                        echo "Smoke test passed!"
                    }
                }
            }
        }
    }

    post {
        always {
            echo "Cleaning up Docker container..."
            sh "docker rm -f ${CONTAINER_NAME} || true"
        }
    }
}
