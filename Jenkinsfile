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
          archive = "${WORKSPACE}/mirror-${BUILD_NUMBER}.tar.gz"
        }
        echo "Deploying API (mirror-${BUILD_NUMBER}.tar.gz)..."
        sh "tar -cvzf ${archive} -C ${WORKSPACE}/_build ."
        sh "pv ${archive} | ssh deploy@192.241.152.231 'cat | tar xz -C /var/www/mirror'"
        echo 'Successfully deployed API'
      }
    }
    stage('Start API') {

      steps {
        echo "Starting API..."
        sh "cat startup.sh | ssh deploy@192.241.152.231"
        echo 'Successfully started API'
      }
    }
  }
  post {
    always {
      sh "sudo chmod -R 777 ."
    }
  }
}