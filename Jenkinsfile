properties([
  parameters([
    booleanParam(defaultValue: false, description: 'If set to true, on completion of docker build, the API image will be deployed to production', name: 'deploy_api_to_prod'),
    booleanParam(defaultValue: false, description: 'If set to true, on completion of docker build, the client image will be deployed to production', name: 'deploy_client_to_prod')
  ])
])

node {
  def commitId = sh(returnStdout: true, script: 'git rev-parse HEAD')
  def buildNumber = currentBuild.number
  
  try {
    stage("Build") {
      parallel (
        "API": {
          echo 'Building API...'
          sh "docker build -t nonbreakingspace/mirror-api:${commitId} ./api"
          sh "docker tag nonbreakingspace/mirror-api:${commitId} nonbreakingspace/mirror-api:latest"
          echo 'Successfully built API'
        },
        "Client": {
          echo 'Building Client...'
          // sh "docker build -t nonbreakingspace/mirror-client:${commitId} ./client"
          // sh "docker tag nonbreakingspace/mirror-client:${commitId} nonbreakingspace/mirror-client:latest"
          echo 'Successfully built Client'
        }
      )
    }
    stage('Push to Docker Hub') {
      parallel(
        "API": {
          echo 'Pushing API to Docker Hub...'
          docker.withRegistry('https://index.docker.io/v1/', 'docker-hub-credentials-id') {
            sh "docker push nonbreakingspace/mirror-api"
          }
          echo 'Successfully pushed API to Docker Hub'
        },
        "Client": {
          echo 'Pushing Client to Docker Hub...'
          // docker.withRegistry('https://index.docker.io/v1/', 'docker-hub-credentials-id') {
          //   sh "docker push nonbreakingspace/mirror-client"
          // }
          //
          echo 'Successfully pushed Client to Docker Hub'
        }
      )
    }
    stage('Deploy API to Production') {
      if(params.deploy_api_to_prod) {
        parallel (
          "Tag Release Build": {
            echo "Tagging current build as the release build..."
            sh "docker tag nonbreakingspace/mirror-api:${commitId} nonbreakingspace/mirror-api:release"
            docker.withRegistry('https://index.docker.io/v1/', 'docker-hub-credentials-id') {
              sh "docker push nonbreakingspace/mirror-api"
            }
            echo "Build has been tagged as release and pushed to Docker Hub"
          },
          "Rollout on Kubernetes Cluster": {
            echo 'Rolling deployment to Kubernetes cluster...'
            sh "kubectl --kubeconfig='./kubeconfig.yaml' set image deployment.apps/mirror-api mirror-api=nonbreakingspace/mirror-api:${commitId} --record"
            sh "kubectl --kubeconfig='./kubeconfig.yaml' rollout status deployment.apps/mirror-api"
            echo 'Successfully deployed to production'
          }
        )
      } else {
        echo 'No deployment to production was requested'
      }
    }
    stage('Deploy Client to Production') {
      if(params.deploy_client_to_prod) {
        parallel (
          "Tag Release Build": {
            echo "Tagging current build as the release build..."
            sh "docker tag nonbreakingspace/mirror-client:${commitId} nonbreakingspace/mirror-client:release"
            docker.withRegistry('https://index.docker.io/v1/', 'docker-hub-credentials-id') {
              sh "docker push nonbreakingspace/mirror-client"
            }
            echo "Build has been tagged as release and pushed to Docker Hub"
          },
          "Rollout on Kubernetes Cluster": {
            echo 'Rolling deployment to Kubernetes cluster...'
            sh "kubectl --kubeconfig='./kubeconfig.yaml' set image deployment.apps/mirror-client mirror-client=nonbreakingspace/mirror-client:${commitId} --record"
            sh "kubectl --kubeconfig='./kubeconfig.yaml' rollout status deployment.apps/mirror-client"
            echo 'Successfully deployed to production'
          }
        )
      } else {
        echo 'No deployment to production was requested'
      }
    }
  } catch(e) {
    echo "Pipeline failed"
    throw e
  } finally {
    sh "sudo chmod -R 777 ."
  }
}