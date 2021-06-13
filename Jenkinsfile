pipeline {
    agent any

    tools {nodejs "nodejs"}
    
    environment {
        BRANCH='master'
    }

    stages {
        stage('Install dependencies') {
            steps {
                sh '''
                    npm install
                '''
            }
        }

        stage('Build staging') {
            steps {
                sh '''
                    npm run stage
                '''
            }
        }
        stage('Archive staging') {
            steps {
                sh '''
                    tar -zcvf app-build-staging-${BRANCH}-${BUILD_NUMBER}.tar.gz build/
                '''
            }
        }

        stage('Upload staging') {
            steps {
                withAWS(region:'eu-central-1',credentials:'devops-aws-credential') {
                s3Upload(file:"app-build-staging-${BRANCH}-${BUILD_NUMBER}.tar.gz", bucket:'devopstask-app-archive', path:'staging/');
                s3Upload(file:'build/', bucket:'devopstask-app-staging');
                }
            }
        }

        stage('Build production') {
            steps {
                sh '''
                    npm run prod
                '''
            }
        }
        stage('Archive production') {
            steps {
                sh '''
                    tar -zcvf app-build-production-${BRANCH}-${BUILD_NUMBER}.tar.gz build/
                '''
            }
        }
        stage('Upload production archive') {
            steps {
                withAWS(region:'eu-central-1',credentials:'devops-aws-credential') {
                s3Upload(file:"app-build-production-${BRANCH}-${BUILD_NUMBER}.tar.gz", bucket:'devopstask-app-archive', path:'production/');
                }
            }
        }
    }
}