pipeline {
    agent any
    environment {
        AWS_ACCESS_KEY_ID = credentials('jenkins-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('jenkins-secret-access-key')
        REGION = "us-east-1"
        AWS_S3_BUCKET = "sudos-tawazun1-s3bucket"  //change
        ARTIFACT_NAME = "duihua.war"
        AWS_EB_APP_NAME = "sudos-duihua-app"
        AWS_EB_APP_VERSION = "${BUILD_ID}"
        AWS_EB_ENVIRONMENT = "sudos-duihua-env" 
        SONAR_IP = "3.82.143.230"  //change
        SONAR_PROJECT = "sudos"     //change
        SONAR_TOKEN = "3794d439cf6df32cfd520133690707e35ff58ad7"  //change
    }
    stages {
        stage('Validate') {
            steps {
                sh "mvn validate"

                sh "mvn clean"
            }
        }
        stage('Build') {
            steps {
                sh "mvn compile"
            }
        }
        stage('Test') {
            steps {
                sh "mvn test"
            }
            //post{
                //always{
                    //junit '**/target/surefire-reports/TEST-*.xml'
                //}
            //}
        }

        stage('Quality Scan'){
            steps {
               sh '''
                    mvn clean verify sonar:sonar \
                    -Dsonar.projectKey=$SONAR_PROJECT \
                    -Dsonar.host.url=http://$SONAR_IP:9000 \
                    -Dsonar.login=$SONAR_TOKEN
                '''
            }
        }
        stage('Package') {
            steps {
                sh "mvn package"
            }
            post{
                success{
                    archiveArtifacts artifacts: 'target/*.war', followSymlinks: false
                }
            }
        }
        stage('Publish artifacts to S3 Bucket') {
            steps {
                sh "aws configure set region $REGION"
                sh "aws s3 cp ./target/*.war s3://$AWS_S3_BUCKET/$ARTIFACT_NAME"
            }
         }
        stage ("terraform init") {
            steps {
                sh ('terraform -chdir=Terraform/modules/aws-elasticbeanstalk-cloudfront init') 
            }
        }
        stage ("terraform apply elasticbeanstalk") {
            steps {
                sh ('terraform -chdir=Terraform/modules/aws-elasticbeanstalk-cloudfront apply -target="aws_elastic_beanstalk_application.sudos-duihua-app" -target="aws_elastic_beanstalk_environment.sudos-duihua-env" --auto-approve')
           }
        }
        stage('Deploy') {
            steps {
                sh 'aws elasticbeanstalk create-application-version --application-name $AWS_EB_APP_NAME --version-label $AWS_EB_APP_VERSION --source-bundle S3Bucket=$AWS_S3_BUCKET,S3Key=$ARTIFACT_NAME'
                sh 'aws elasticbeanstalk update-environment --application-name $AWS_EB_APP_NAME --environment-name $AWS_EB_ENVIRONMENT --version-label $AWS_EB_APP_VERSION'
            }
         }
        stage ("terraform apply cloudfront") {
            steps {
                sh ('terraform -chdir=Terraform/modules/aws-elasticbeanstalk-cloudfront apply -target="aws_cloudfront_distribution.distribution" --auto-approve')
           }
        }
        

    }
}