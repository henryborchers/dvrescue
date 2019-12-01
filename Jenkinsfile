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
                        values  'ci/jenkins/docker/build/centos7/Dockerfile', "ci/jenkins/docker/build/centos8/Dockerfile", "ci/jenkins/docker/build/fedora31/Dockerfile", "ci/jenkins/docker/build/ubuntu1604/Dockerfile" ,"ci/jenkins/docker/build/ubuntu1804/Dockerfile"
                    }
                }
                environment{
                    PATH="/home/user/.local/bin:${PATH}"
                }
                stages {
                    stage("Install ZenLib"){
                        steps{
                            sh "ls -la /home/user"

                            sh "echo $PATH"
                            sh "whoami"
                            dir("ZenLib"){
                                git 'https://github.com/MediaArea/ZenLib.git'
                            }
                            dir("ZenLib/build"){
                                sh "cmake ${WORKSPACE}/ZenLib/Project/CMake -DCMAKE_INSTALL_PREFIX:PATH=/home/user/.local"
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
                                sh "cmake ${WORKSPACE}/MediaInfoLib/Project/CMake -DCMAKE_INSTALL_PREFIX:PATH=/home/user/.local"
                                sh "cmake --build . --target install"
                            }
                        }
                    }
                    stage('Build') {
                        steps {
                            cmakeBuild(
                                buildDir: 'build',
                                cmakeArgs: "-DCMAKE_INSTALL_PREFIX:PATH=/home/user/.local -DCMAKE_MODULE_PATH:PATH=/home/user/.local",
                                installation: 'InSearchPath',
                                steps: [
                                    [withCmake: true]
                                ]
                            )
                            sh "build/Source/dvrescue --version"
                        }
                    }
                    stage('Install') {
                        steps {
                            cmakeBuild(
                                buildDir: 'build',
                                cmakeArgs: "-DCMAKE_INSTALL_PREFIX:PATH=/home/user/.local -DCMAKE_MODULE_PATH:PATH=/home/user/.local",
                                installation: 'InSearchPath',
                                steps: [
//                                    [withCmake: true]
                                    [args: '--target install', withCmake: true]
                                ]
                            )
//                            dir("build"){
//                                sh "make install"
//                            }

                            sh "echo $PATH"
                            sh "whoami"
                            sh "ls -la /home/user/.local/bin"
                            sh(script: "which dvrescue", returnStatus: true)
                            sh(script: "cd /home/user/.local/bin && ls -la", returnStatus: true)
//                                sh(script: "which dvrescue", returnStatus: true)
                            sh "dvrescue --version"
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
