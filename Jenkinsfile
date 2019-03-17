properties([
  parameters([
    booleanParam(defaultValue: false, description: 'If set to true, on completion of docker build, the API image will be deployed to production', name: 'deploy_api_to_prod'),
    booleanParam(defaultValue: false, description: 'If set to true, on completion of docker build, the client image will be deployed to production', name: 'deploy_client_to_prod'),
    booleanParam(defaultValue: false, description: 'If set to true, on completion of docker build, any new database migrations will be run', name: 'run_database_migrations')
  ])
])

node {
  checkout scm
  def commitId = "`git rev-parse HEAD`"
  def deployAPI = sh (
      script: "git log -1 --pretty=%B | grep '\\[ci deploy api]'",
      returnStatus: true
  ) == 0
  def deployClient = sh (
      script: "git log -1 --pretty=%B | grep '\\[ci deploy client]'",
      returnStatus: true
  ) == 0
  def runMigrations = sh (
      script: "git log -1 --pretty=%B | grep '\\[ci run migrations]'",
      returnStatus: true
  ) == 0
  def deployAll = sh (
      script: "git log -1 --pretty=%B | grep '\\[ci deploy all]'",
      returnStatus: true
  ) == 0
  
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
          sh "docker build -t scottyd980/mirror-client:${commitId} ./client"
          sh "docker tag scottyd980/mirror-client:${commitId} scottyd980/mirror-client:latest"
          echo 'Successfully built Client'
        }
      )
    }
    stage("Test") {
      echo "Testing Client..."
      sh "docker build -t scottyd980/mirror-client-test:latest ./client --target build"
      sh "docker run --rm -e CI=true scottyd980/mirror-client-test:latest ember test"
      echo "Successfully tested Client"
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
          docker.withRegistry('https://index.docker.io/v1/', 'docker-personal-credentials-id') {
            sh "docker push scottyd980/mirror-client"
          }
          echo 'Successfully pushed Client to Docker Hub'
        }
      )
    }
    stage('Update Kubernetes Config YAML') {
      if(params.deploy_api_to_prod || deployAPI || params.deploy_client_to_prod || deployClient || deployAll) {
        withCredentials([string(credentialsId: 'digital-ocean-credentials-id', variable: 'DO_OAUTH')]) {
          sh """
            curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer ${env.DO_OAUTH}" "https://api.digitalocean.com/v2/kubernetes/clusters/be06bc7a-8740-4934-95cc-2ef420f1f6d7/kubeconfig" -o ./kubeconfig.yaml
          """
        }
      }
    }
    stage('Run Database Migrations') {
      if(params.run_database_migrations || runMigrations || deployAll) {
        withCredentials([string(credentialsId: 'DB_HOST', variable: 'DB_HOST'), string(credentialsId: 'USERNAME', variable: 'USERNAME'), string(credentialsId: 'PASSWORD', variable: 'PASSWORD'), string(credentialsId: 'DATABASE', variable: 'DATABASE')]) {
          sh "docker build --target build -t nonbreakingspace/mirror-api-migrator:latest ./api"
          sh "docker run --env DB_HOST=${env.DB_HOST} --env USERNAME=${env.USERNAME} --env PASSWORD=${env.PASSWORD} --env DATABASE=${env.DATABASE} --env MIX_ENV=migration nonbreakingspace/mirror-api-migrator:latest mix ecto.migrate"
        }
      }
    }
    stage('Deploy API to Production') {
      if(params.deploy_api_to_prod || deployAPI || deployAll) {
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
            sh "id -a"
            sh "kubectl --kubeconfig='./kubeconfig.yaml' set image deployment.apps/mirror-backend mirror=nonbreakingspace/mirror-api:${commitId} --record"
            sh "kubectl --kubeconfig='./kubeconfig.yaml' rollout status deployment.apps/mirror-backend"
            echo 'Successfully deployed to production'
          }
        )
      } else {
        echo 'No deployment to production was requested'
      }
    }
    stage('Deploy Client to Production') {
      if(params.deploy_client_to_prod || deployClient || deployAll) {
        parallel (
          "Tag Release Build": {
            echo "Tagging current build as the release build..."
            // sh "docker tag nonbreakingspace/mirror-client:${commitId} nonbreakingspace/mirror-client:release"
            // docker.withRegistry('https://index.docker.io/v1/', 'docker-hub-credentials-id') {
            //   sh "docker push nonbreakingspace/mirror-client"
            // }
            sh "docker tag scottyd980/mirror-client:${commitId} scottyd980/mirror-client:release"
            docker.withRegistry('https://index.docker.io/v1/', 'docker-personal-credentials-id') {
              sh "docker push scottyd980/mirror-client"
            }
            echo "Build has been tagged as release and pushed to Docker Hub"
          },
          "Rollout on Kubernetes Cluster": {
            echo 'Rolling deployment to Kubernetes cluster...'
            // sh "kubectl --kubeconfig='./kubeconfig.yaml' set image deployment.apps/mirror-frontend mirror=nonbreakingspace/mirror-client:${commitId} --record"
            // sh "kubectl --kubeconfig='./kubeconfig.yaml' rollout status deployment.apps/mirror-frontend"
            sh "kubectl --kubeconfig='./kubeconfig.yaml' set image deployment.apps/mirror-frontend mirror=scottyd980/mirror-client:${commitId} --record"
            sh "kubectl --kubeconfig='./kubeconfig.yaml' rollout status deployment.apps/mirror-frontend"
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
    echo 'Cleaning up docker images...'
    sh "docker image rm `docker image ls --filter reference='nonbreakingspace/mirror-api' --quiet` --force"
    // sh "docker image rm `docker image ls --filter reference='nonbreakingspace/mirror-client' --quiet` --force"
    sh "docker image rm `docker image ls --filter reference='scottyd980/mirror-client' --quiet` --force"
    echo 'Cleaned up docker images'
  }
}