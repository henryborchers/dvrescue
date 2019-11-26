pipeline {
    agent none
    stages {
        stage('Build') {
            matrix {
                agent {
                    dockerfile {
                        filename "${PLATFORM}"
                        label 'linux && docker'
                    }
                }
                axes {
                    axis {
                        name 'PLATFORM'
                        values 'ci/jenkins/docker/build/centos6/Dockerfile', 'ci/jenkins/docker/build/centos7/Dockerfile', "ci/jenkins/docker/build/centos8/Dockerfile", "ci/jenkins/docker/build/fedora31/Dockerfile", "ci/jenkins/docker/build/ubuntu1604/Dockerfile" ,"ci/jenkins/docker/build/ubuntu1804/Dockerfile"
                    }
                }
                stages {
                    stage('Build') {
                        steps {
                            sh "git clone https://github.com/MediaArea/ZenLib.git"
                            cmakeBuild buildDir: 'build', installation: 'InSearchPath', steps: [[withCmake: true]]
                        }
                    }
                }
            }
        }
    }
}
