@Library('SeaTrial')
import com.twig_world.seatrial.Utils

pipeline {
    agent none

    environment {

        String family = 'INFRA'
        String environment = 'k8s-nonprod'
        String application = new Utils().getRepoName()
        String prefix = "/${family}/${environment}/${application}"
        
        String slaveCredsId = 'jenkins-aws-credentials' 
        String gitCredsId = 'jenkins-github-https' 
        
        String registryHost = '817276302724.dkr.ecr.eu-west-1.amazonaws.com' 
        String repositoryName = "${family}/${application}".toLowerCase() 
        String imageName = "${registryHost}/${repositoryName}"
        
        String imageTag = new Utils().getImageTag() 

    }

    stages {
        stage('Build & Push Docker Image') {
            agent { label 'docker' }
            steps {
                composeBuild (
                    registryHost: registryHost,
                    repoName: repositoryName,
                    imageTag: imageTag,
                    commands: ['make build'],
                )
            }
        }

        stage('Test') {
            parallel {
                stage('Test on K8s') {
                    agent { label 'eks3-eu-west-1' }
                    environment {
                        environment = 'k8s-nonprod'
                        prefix = "/${family}/${environment}/${application}"
                    }
                    steps {
                        script {
                            def utils = new Utils()
                            def accessKey = utils.getSsmParameter(slaveCredsId, prefix, 'AWS_ACCESS_KEY_ID').Value
                            def secretKey = utils.getSsmParameter(slaveCredsId, prefix, 'AWS_SECRET_ACCESS_KEY').Value
                            helm (
                                imageTag: imageTag,
                                namespace: 'ci',
                                valuesFile: 'values.yaml',
                                awsAccessKey: accessKey,
                                awsSecretKey: secretKey,
                                autodelete: true
                            )
                        }
                    }
                }
            }
        }

        stage('Publish') {
            agent { label 'docker' }
            steps {
                script {
                    def utils = new Utils()
                    utils.publishImageTags(imageName, imageTag)
                    utils.publishGitTag(gitCredsId)
                }
            }
        }
        
        stage('Trigger Downstream') {
            agent { label 'master' }
            steps {
                script {
                    if ( env.BRANCH_NAME == 'master' ) {
                        build (
                            job: "${family}_${application}_Deploy",
                            parameters: [
                                [$class: 'StringParameterValue', name: 'GIT_VERSION', value: env.GIT_COMMIT]
                            ]
                        )
                    } else {
                        org.jenkinsci.plugins.pipeline.modeldefinition.Utils.markStageSkippedForConditional(STAGE_NAME)
                    }
                }
            }
        }
    }
    post {
        failure {
            script {
                if ( env.BRANCH_NAME == 'master' ) {
                    slackSend channel: '#webteam',
                              color: 'danger', 
                              message: "${currentBuild.fullDisplayName}\nBuild failure on master branch"
                } 
            }
        }
    }
}
