def load_configurations(){
    node{
        checkout scm
        def config = [
            "centos-7": [
                os:"centos",
                os_family: "linux",
                version:"7",
                agents:[
                    build:[
                        dockerfile:"ci/jenkins/docker/build/centos-7/Dockerfile",
                        label: "linux && docker",
                        additionalBuildArgs: '--build-arg USER_ID=$(id -u) --build-arg GROUP_ID=$(id -g)'
                    ],
                    test:[
                        dockerImage: "centos:7"
                    ]
                ]
            ],
            "centos-8": [
                os: "centos",
                os_family: "linux",
                version:"8",
                agents:[
                    build:[
                        dockerfile: "ci/jenkins/docker/build/centos-8/Dockerfile",
                        label: "linux && docker",
                        additionalBuildArgs: '--build-arg USER_ID=$(id -u) --build-arg GROUP_ID=$(id -g)'
                    ],
                    test:[
                        dockerImage: "centos:8"
                    ]
                ]
            ],
            "fedora-31": [
                os: "fedora",
                os_family: "linux",
                version: "31",
                agents:[
                    build:[
                        dockerfile:"ci/jenkins/docker/build/fedora-31/Dockerfile",
                        label: "linux && docker",
                        additionalBuildArgs: '--build-arg USER_ID=$(id -u) --build-arg GROUP_ID=$(id -g)'
                    ],
                    test:[
                        dockerImage: "fedora:31"
                    ]
                ]
            ],
            "ubuntu-16.04":[
                os:"ubuntu",
                os_family: "linux",
                version:"16.04",
                agents:[
                    build:[
                        dockerfile:"ci/jenkins/docker/build/ubuntu-16.04/Dockerfile",
                        label: "linux && docker",
                        additionalBuildArgs: '--build-arg USER_ID=$(id -u) --build-arg GROUP_ID=$(id -g)'
                    ],
                    test:[
                        dockerImage: "ubuntu:16.04"
                    ]
                ]
            ],
            "ubuntu-18.04":[
                os:"ubuntu",
                os_family: "linux",
                version:"18.04",
                agents:[
                    build:[
                        dockerfile:"ci/jenkins/docker/build/ubuntu-18.04/Dockerfile",
                        label: "linux && docker",
                        additionalBuildArgs: '--build-arg USER_ID=$(id -u) --build-arg GROUP_ID=$(id -g)'
                    ],
                    test:[
                        dockerImage: "ubuntu:18.04"
                    ]
                ]
            ]
        ]
//         def config = readYaml(file: "ci/jenkins/configurations.yml")
//         echo "config = ${config}"
        return config
    }
}
def CONFIGURATIONS = load_configurations()
pipeline {
    agent none
    stages {
        stage('Build') {
            matrix {
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
                agent {
                    dockerfile {
                        filename CONFIGURATIONS[PLATFORM].agents.build.dockerfile
                        label CONFIGURATIONS[PLATFORM].agents.build.label
                        additionalBuildArgs "${CONFIGURATIONS[PLATFORM].agents.build.additionalBuildArgs}"
                    }
                }
                stages {
                    stage('Build dvrescue') {
                        steps {
//                             script{
                            echo "CONFIGURATIONS = ${CONFIGURATIONS[PLATFORM]}"
//                             }
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
                    stage("Package dvrescue"){
                        steps{
                            dir("build"){
                            // This environment variable is set in the docker file
                                sh 'cpack -G $CPACK_GENERATOR --verbose --debug'


                            }
                        }
                        post{
                            success{
                                dir("build"){
                                    stash includes: '*.rpm,*.deb', name: "${PLATFORM}-PACKAGE"
                                    script{
                                        if(PLATFORM.contains("ubuntu")){
                                            sh "cat ${findFiles(glob: '**/control')[0]}"
                                        }
                                         if(PLATFORM.contains("centos") || PLATFORM.contains("fedora")){
                                            sh "cat ${findFiles(glob: '**/dvrescue.spec')[0]}"
                                        }
                                    }
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
                agent {
                    label 'linux && docker'
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
                    stage("Install Package"){
                        options{
                             skipDefaultCheckout true
                        }
                        steps{
                            echo "Testing installing on ${PLATFORM}"
                            script{
                                def test_machine = docker.image(CONFIGURATIONS[PLATFORM].agents.test.dockerImage)
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
