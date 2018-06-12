pipeline {
  agent any
  stages {
    stage('Build API') {
      steps {
        sh 'docker build -t mirror ./api'
        sh 'docker run --rm mirror -v ${PWD}:/_build'
      }
    }
  }
}