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
                    stage("Install ZenLib"){
                        steps{
                            dir("ZenLib"){
                                git 'https://github.com/MediaArea/ZenLib.git'
                            }
                            dir("ZenLib/Project/GNU/Library"){
                                sh "sh autogen.sh && ./configure --prefix=${WORKSPACE}/.local && make && make install"
                            }
                        }
                    }
                    stage("Install MediaInfoLib"){
                        steps{
                            dir("MediaInfoLib"){
                                git 'https://github.com/MediaArea/MediaInfoLib.git'
                            }
                            dir("MediaInfoLib/Project/GNU/Library"){
                                sh "sh autogen.sh && ./configure --prefix=${WORKSPACE}/.local && make && make install"
                            }
                        }
                    }
                    stage('Build') {
                        steps {
                            cmakeBuild buildDir: 'build', installation: 'InSearchPath', steps: [[withCmake: true]]
                        }
                    }
                }
                post{
                    cleanup{
                        cleanWs()
                    }
                }
            }
        }
    }
}
