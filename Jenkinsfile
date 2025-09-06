pipeline {
    agent any

    environment {
        IMAGE_NAME = "saiswaroopa08/flask-ci-demo:latest"
        CONTAINER_NAME = "flask-ci-container"
        DOCKER_CRED = "Dockerhub-flask"
    }

    stages {
        stage('Checkout SCM') {
            steps {
                git branch: 'main', url: 'https://github.com/swaroopasgit/flask-ci-cd-demo.git', credentialsId: 'flask-ci-cd'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${IMAGE_NAME} ."
            }
        }

        stage('Docker Login & Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: "${DOCKER_CRED}", passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                    sh "docker push ${IMAGE_NAME}"
                }
            }
        }

        stage('Deploy Container') {
            steps {
                script {
                    // Stop and remove previous container if exists
                    sh "docker rm -f ${CONTAINER_NAME} || true"

                    // Find an available port starting from 5000
                    def hostPort = 5000
                    while (sh(script: "lsof -i :${hostPort}", returnStatus: true) == 0) {
                        hostPort += 1
                    }

                    // Run container
                    sh "docker run -d --name ${CONTAINER_NAME} -p ${hostPort}:5000 ${IMAGE_NAME}"
                    echo "Container running on host port ${hostPort}"

                    // Save port for smoke test
                    env.HOST_PORT = hostPort.toString()
                }
            }
        }

        stage('Smoke Test') {
            steps {
                script {
                    def testStatus = sh(script: "curl -s -o /dev/null -w '%{http_code}' http://localhost:${env.HOST_PORT}", returnStdout: true).trim()
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
