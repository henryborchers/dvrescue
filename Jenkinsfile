def load_configurations(){
    node{
        checkout scm
        return readYaml(file: "ci/jenkins/configurations.yml").configurations
    }
}
def CONFIGURATIONS = load_configurations()
pipeline {
    agent none
    parameters {
      booleanParam defaultValue: true, description: 'Build for windows', name: 'BuildWindows'
      booleanParam defaultValue: true, description: 'Build for linux', name: 'BuildLinux'
    }
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
                            'fedora-31-nocurl',
                            'ubuntu-16.04',
                            'ubuntu-16.04-nocurl',
                            'ubuntu-18.04',
                            "visual-studio-2019"
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
                when {
                    anyOf{
                        allOf{
                            expression { params.BuildWindows == true }
                            expression { CONFIGURATIONS[PLATFORM].os_family == "windows"}
                        }
                        allOf{
                            expression { params.BuildLinux == true }
                            expression { CONFIGURATIONS[PLATFORM].os_family == "linux"}
                        }
                    }
                    beforeAgent true
                }
                stages {
                    stage('Build dvrescue') {
                        steps {
                            cmakeBuild(
                                buildDir: CONFIGURATIONS[PLATFORM].agents.build.build_dir,
                                installation: 'InSearchPath',
                                buildType: 'Release',
                                steps: [
                                    [
                                        args: '--config Release',
                                        withCmake: true,
                                    ]
                                ]
                            )
                            script{
                                if(isUnix()){
                                    def dvrescue_executable = findFiles(glob: '**/dvrescue')[0]
                                    echo "Location of dvrescue ${dvrescue_executable}"
                                    sh "build/Source/dvrescue --version"
                                } else{
                                    bat "set"
                                    bat "cd ${CONFIGURATIONS[PLATFORM].agents.build.build_dir}\\Source\\Release && dvrescue.exe --version"
                                }
                            }
                        }
                        post{
                            failure{
                                script{
                                    if(isUnix()){
                                        sh "ls -R"
                                    }else{
                                            timeout(time: 10, unit: 'SECONDS') {
                                                bat(
                                                script: "cd ${CONFIGURATIONS[PLATFORM].agents.build.build_dir}\\Source\\Debug && dir && dumpbin /DEPENDENTS dvrescue.exe",
                                                returnStatus: true
                                                )
                                        }
                                    }
                                }
                            }
                        }
                    }
                    stage("Package dvrescue"){
                        steps{
                            cpack(
                                arguments: "-G ${CONFIGURATIONS[PLATFORM].agents.build.cpack_generator}",
                                installation: 'InSearchPath',
                                workingDir: "${CONFIGURATIONS[PLATFORM].agents.build.build_dir}"
                                )
                        }
                        post{
                            success{
                                script{
                                    if(CONFIGURATIONS[PLATFORM].os_family == "windows"){
                                        bat "if not exist build mkdir build"
                                        bat "cd build && copy ${CONFIGURATIONS[PLATFORM].agents.build.build_dir}\\*.msi"
                                    }
                                }
                                dir("build"){
                                    stash includes: '*.rpm,*.deb,*.msi', name: "${PLATFORM}-PACKAGE"
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
                            script{
                                if(isUnix()){
                                   dir("build"){
                                       sh "sudo cmake --build . --target install"
                                   }
                                    sh "dvrescue --version"
                                }
                            }
                        }
                        post{
                            cleanup{
                                script{
                                    if(isUnix()){
                                        sh "sudo rm -rf build"
                                    }
                                }
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
                when {
                    anyOf{
                        allOf{
                            expression { params.BuildWindows == true }
                            expression { CONFIGURATIONS[PLATFORM].os_family == "windows"}
                        }
                        allOf{
                            expression { params.BuildLinux == true }
                            expression { CONFIGURATIONS[PLATFORM].os_family == "linux"}
                        }
                    }
                    beforeAgent true
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
