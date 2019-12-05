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
                            'centos-7',
                            'centos-8',
                            'fedora-31',
                            'ubuntu-16.04',
                            'ubuntu-18.04'
                            )
                    }
                }
                stages {
//                     stage("Install ZenLib"){
//                         steps{
//                             dir("ZenLib"){
//                                 git 'https://github.com/MediaArea/ZenLib.git'
//                             }
//                             dir("ZenLib/build"){
//                                 sh "cmake ${WORKSPACE}/ZenLib/Project/CMake -G Ninja"
//                                 sh "sudo cmake --build . --target install"
//                             }
//                         }
//                     }
//                     stage("Install MediaInfoLib"){
//                         steps{
//                             dir("MediaInfoLib"){
//                                 git 'https://github.com/MediaArea/MediaInfoLib.git'
//                             }
//                             dir("MediaInfoLib/build"){
//                                 sh "cmake ${WORKSPACE}/MediaInfoLib/Project/CMake -G Ninja"
//                                 sh "sudo cmake --build . --target install"
//                             }
//                         }
//                     }
                    stage('Build dvrescue') {
                        steps {
                            sh "pkg-config --list-all"
                            sh "pkg-config --libs-only-L libzen"
                            sh "which dpkg-shlibdeps"
                            cmakeBuild(
                                buildDir: 'build',
                                installation: 'InSearchPath',
                                cmakeArgs: "-DCMAKE_INSTALL_RPATH=/usr/local/lib",
//                                 cmakeArgs: "-DCMAKE_INSTALL_RPATH=/usr/local/lib;/usr/lib",
                                steps: [
                                    [withCmake: true]
                                ]
                            )
                            sh "build/Source/dvrescue --version"
                        }
                    }
                    stage("Package dvrescue"){
                        steps{
                            dir("build"){
                            // This environment variable is set in the docker file
                                sh 'cpack -G $CPACK_GENERATOR --verbose --debug --trace'
                                sh 'ls -R _CPack_Packages '
                                sh "cat ${findFiles(glob: '**/control')[0]}"
                            }
                        }
                        post{
                            success{
                                dir("build"){
                                    stash includes: '*.rpm,*.deb', name: "${PLATFORM}-PACKAGE"
                                }
                            }
                            cleanup{
                                cleanWs(
                                    patterns: [
                                            [pattern: 'build/*.rpm', type: 'INCLUDE'],
                                            [pattern: 'build/*.deb', type: 'INCLUDE']
                                        ]
                                    )
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
                            cleanup{
                                sh "sudo rm -rf build"
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
        stage("Testing Install Package"){
            matrix{
                agent any
                axes {
                    axis {
                        name 'PLATFORM'
                        values(
//                             'centos-7',
//                             'centos-8',
//                             'fedora-31',
                            'ubuntu-16.04',
                            'ubuntu-18.04'
                            )
                    }
                }
                stages {
                    stage("Install Package"){
                        options{
                             skipDefaultCheckout true
                        }
                        steps{
                            echo "Testing installing on ${PLATFORM}"
                            script{
                                def parts = "${PLATFORM}".split('-')
                                def dockerImage = "${parts[0]}:${parts[1]}"
                                echo "Creating a new container based on ${dockerImage}"
                                def test_machine = docker.image("${dockerImage}")
                                test_machine.inside("--user root") {
                                    unstash "${PLATFORM}-PACKAGE"

                                    if(PLATFORM.contains("ubuntu")){
                                        sh "apt update && apt-get install -y -f ./${findFiles(glob: '*.deb')[0]}"
                                    }

                                    if(PLATFORM.contains("fedora")){
                                        sh "dnf -y localinstall ./${findFiles(glob: '*.rpm')[0]}"
                                    }
                                    if(PLATFORM.contains("centos")){
                                        sh "yum -y update"
                                        sh "yum install -y epel-release"
                                        sh "yum -y localinstall ./${findFiles(glob: '*.rpm')[0]}"
                                    }

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
    }
}
