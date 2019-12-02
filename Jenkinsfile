pipeline {
    agent none
    stages {
        stage('Build') {
            matrix {
                agent {
                    dockerfile {
                        filename "ci/jenkins/docker/build/${PLATFORM}/Dockerfile"
                        label 'linux && docker'
                        additionalBuildArgs '--build-arg USER_ID=$(id -u) --build-arg GROUP_ID=$(id -g)'
                    }
                }
                axes {
                    axis {
                        name 'PLATFORM'
                        values(
                            'centos7',
                            'centos8',
                            'fedora31',
                            'ubuntu1604',
                            'ubuntu1804'
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
