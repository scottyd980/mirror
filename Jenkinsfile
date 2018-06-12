pipeline {
  agent any
  stages {
    stage('Build API') {
      steps {
        sh 'docker build -t mirror ./api'
        sh 'docker ps'
        sh 'docker run --rm -v ${PWD}:/_build mirror'
      }
    }
  }
}