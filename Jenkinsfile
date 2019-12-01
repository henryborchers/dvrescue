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
                        values  'ci/jenkins/docker/build/centos7/Dockerfile', "ci/jenkins/docker/build/centos8/Dockerfile", "ci/jenkins/docker/build/fedora31/Dockerfile", "ci/jenkins/docker/build/ubuntu1604/Dockerfile" ,"ci/jenkins/docker/build/ubuntu1804/Dockerfile"
                    }
                }
                stages {
                    stage("Install ZenLib"){
                        steps{
                            dir("ZenLib"){
                                git 'https://github.com/MediaArea/ZenLib.git'
                            }
                            dir("ZenLib/build"){
                                sh "cmake ${WORKSPACE}/ZenLib/Project/CMake -DCMAKE_INSTALL_PREFIX:PATH=${WORKSPACE}/.local"
                                sh "cmake --build . --target install"
                            }
                        }
                    }
                    stage("Install MediaInfoLib"){
                        steps{
                            dir("MediaInfoLib"){
                                git 'https://github.com/MediaArea/MediaInfoLib.git'
                            }
                            dir("MediaInfoLib/build"){
                                sh "cmake ${WORKSPACE}/MediaInfoLib/Project/CMake -DCMAKE_INSTALL_PREFIX:PATH=${WORKSPACE}/.local"
                                sh "cmake --build . --target install"
                            }
                        }
                    }
                    stage('Build') {
                        steps {
                            cmakeBuild(
                                buildDir: 'build',
                                cmakeArgs: "-DCMAKE_INSTALL_PREFIX:PATH=${WORKSPACE}/.local -DCMAKE_MODULE_PATH:PATH=${WORKSPACE}/.local",
                                installation: 'InSearchPath',
                                steps: [
                                    [withCmake: true]
                                ]
                            )
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
