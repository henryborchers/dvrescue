pipeline {
    agent none
    stages {
        stage('Build') {
            matrix {
                agent {
                    dockerfile {
                        filename "${PLATFORM}"
                        label 'linux && docker'
                        additionalBuildArgs '--build-arg USER_ID=$(id -u) --build-arg GROUP_ID=$(id -g)'
                    }
                }
                axes {
                    axis {
                        name 'PLATFORM'
                        values(
                            'ci/jenkins/docker/build/centos7/Dockerfile',
                            "ci/jenkins/docker/build/centos8/Dockerfile",
                            "ci/jenkins/docker/build/fedora31/Dockerfile",
                            "ci/jenkins/docker/build/ubuntu1604/Dockerfile",
                            "ci/jenkins/docker/build/ubuntu1804/Dockerfile"
                            )
                    }
                }
                stages {
                    stage("Install ZenLib"){
                        steps{
                            dir("ZenLib"){
                                git 'https://github.com/MediaArea/ZenLib.git'
                            }
                            dir("ZenLib/build"){
                                sh "cmake ${WORKSPACE}/ZenLib/Project/CMake"
                                sh "sudo cmake --build . --target install"
                            }
                        }
                    }
                    stage("Install MediaInfoLib"){
                        steps{
                            dir("MediaInfoLib"){
                                git 'https://github.com/MediaArea/MediaInfoLib.git'
                            }
                            dir("MediaInfoLib/build"){
                                sh "cmake ${WORKSPACE}/MediaInfoLib/Project/CMake"
                                sh "sudo cmake --build . --target install"
                            }
                        }
                    }
                    stage('Build') {
                        steps {
                            cmakeBuild(
                                buildDir: 'build',
                                installation: 'InSearchPath',
                                steps: [
                                    [withCmake: true]
                                ]
                            )
                            sh "build/Source/dvrescue --version"
                        }
                    }
                    stage("Package"){
                        steps{
                            dir("build"){
                            // This environment variable is set in the docker file
                                sh 'cpack -G $CPACK_GENERATOR'
                            }
                        }
                    }
                    stage('Install') {
                        steps {
                           dir("build"){
                               sh "sudo cmake --build . --target install"
                           }
                            sh "dvrescue --version"
                        }
                        post{
                            failure{
                                sh "ldd /usr/local/bin/dvrescue"
                            }
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
