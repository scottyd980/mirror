pipeline {
  agent any
  stages {
    stage('Build API') {
      steps {
        sh 'docker build -t mirror ./api'
        sh 'docker images'
        sh 'docker run --rm -v ${PWD}/_build:/_build mirror'
      }
    }
  }
  post {
    always {
      sh "chmod -R 777 ."
      cleanWs()
    }
  }
}