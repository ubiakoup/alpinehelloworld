pipeline {
     parameters {
    string(
      name: 'ID_DOCKER_PARAMS',
      defaultValue: 'beranger26',
      description: 'Docker Hub username'
    )
     string(
      name: 'PORT_EXPOSED',
      defaultValue: '80',
      description: 'PORT_EXPOSED'
    )
  }
     environment {
       ID_DOCKER = "${ID_DOCKER_PARAMS}"
       IMAGE_NAME = "alpinehelloworld"
       IMAGE_TAG = "latest"
//       PORT_EXPOSED = "80" à paraméter dans le job
       STAGING = "${ID_DOCKER}-staging"
       PRODUCTION = "${ID_DOCKER}-production"
     }
     agent none
     stages {
         stage('Build image') {
             agent any
             steps {
                script {
                  sh 'docker build -t ${ID_DOCKER}/$IMAGE_NAME:$IMAGE_TAG .'
                }
             }
        }
        stage('Run container based on builded image') {
            agent any
            steps {
               script {
                 sh '''
                    echo "Clean Environment"
                    docker rm -f $IMAGE_NAME || echo "container does not exist"
                    docker run --name $IMAGE_NAME -d -p ${PORT_EXPOSED}:5000 -e PORT=5000 ${ID_DOCKER}/$IMAGE_NAME:$IMAGE_TAG
                    sleep 5
                 '''
               }
            }
       }
       stage('Test image') {
           agent any
           steps {
              script {
                sh '''
                    curl http://192.168.57.100:${PORT_EXPOSED} | grep -q "Hello world!"
                '''
              }
           }
      }
      stage('Clean Container') {
          agent any
          steps {
             script {
               sh '''
                 docker stop $IMAGE_NAME
                 docker rm $IMAGE_NAME
               '''
             }
          }
     }

     stage ('Login and Push Image on docker hub') {
          agent any
        environment {
           DOCKERHUB_PASSWORD  = credentials('dockerhub')
        }            
          steps {
             script {
               sh '''
                   echo $DOCKERHUB_PASSWORD_PSW | docker login -u $ID_DOCKER --password-stdin
                   docker push ${ID_DOCKER}/$IMAGE_NAME:$IMAGE_TAG
               '''
             }
          }
      }    
     
     stage('Push image in staging and deploy it') {
       when {
         branch 'master'
       }
       agent {
         docker {
           image 'node:18-alpine'
           args '-v /var/run/docker.sock:/var/run/docker.sock'
         }
       }
       environment {
         HEROKU_API_KEY = credentials('heroku_api_key')
       }
       steps {
         sh '''
           node -v
           npm install -g heroku@7.68.0
           heroku container:login
           heroku create $STAGING || true
           heroku container:push web -a $STAGING
           heroku container:release web -a $STAGING
         '''
       }
     }
     stage('Push image in production and deploy it') {
       when {
         branch 'production'
       }
       agent {
         docker {
           image 'node:18-alpine'
           args '-v /var/run/docker.sock:/var/run/docker.sock'
         }
       }
       environment {
         HEROKU_API_KEY = credentials('heroku_api_key')
       }
       steps {
         sh '''
           node -v
           npm install -g heroku@7.68.0
           heroku container:login
           heroku create $PRODUCTION || true
           heroku container:push web -a $PRODUCTION
           heroku container:release web -a $PRODUCTION
         '''
       }
     }
  }
}
