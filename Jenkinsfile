pipeline {
  agent any
  stages {
    stage('Build API') {
      steps {
        echo 'Building API...'
        sh 'docker build -t mirror ./api'
        sh 'docker images'
        sh 'docker run --rm -v ${PWD}/_build:/_build mirror'
        echo 'Successfully built API'
      }
    }
    stage('Deploy API') {

      steps {
        script {
          archive = "${PWD}/mirror-${BUILD_NUMBER}.tar.gz"
        }
        echo "Deploying API (${archive})..."
        sh "tar -cvzf ${archive} ${PWD}/_build"
        echo 'Successfully deployed API'
      }
    }
  }
  post {
    always {
      sh "sudo chmod -R 777 ."
    }
  }
}