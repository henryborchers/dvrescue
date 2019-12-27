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
                            'visual-studio-2017-64bit',
                            "visual-studio-2019-32bit",
                            "visual-studio-2019-64bit"
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
                            script{
                                if(isUnix()){
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
                                    def dvrescue_executable = findFiles(glob: '**/dvrescue')[0]
                                    echo "Location of dvrescue ${dvrescue_executable}"
                                    sh "build/Source/dvrescue --version"
                                } else{
                                    bat "cmake -S . -B ${CONFIGURATIONS[PLATFORM].agents.build.build_dir} ${CONFIGURATIONS[PLATFORM].agents.build.cmakeConfigurationArguments}"
                                    bat "cmake --build ${CONFIGURATIONS[PLATFORM].agents.build.build_dir} --config Release"
                                    bat "set"
                                    bat "cd ${CONFIGURATIONS[PLATFORM].agents.build.build_dir}\\Source\\Release && dvrescue.exe --version"
                                    bat "cd ${CONFIGURATIONS[PLATFORM].agents.build.build_dir}\\Source\\Release && dumpbin /DEPENDENTS dvrescue.exe"
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
                            script{
                                if(isUnix()){
                                    cpack(
                                        arguments: "-G ${CONFIGURATIONS[PLATFORM].agents.build.cpack_generator} --verbose",
                                        installation: 'InSearchPath',
                                        workingDir: "${CONFIGURATIONS[PLATFORM].agents.build.build_dir}"
                                        )
                                } else {
                                    bat "cd ${CONFIGURATIONS[PLATFORM].agents.build.build_dir} && cpack -G ${CONFIGURATIONS[PLATFORM].agents.build.cpack_generator} -C Release --verbose"
                                }
                            }
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
                                            [pattern: 'build/*.msi', type: 'INCLUDE'],
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
                                } else{
                                    bat "cmake --build ${CONFIGURATIONS[PLATFORM].agents.build.build_dir} --config Release --target install"
                                    bat "where dvrescue"
                                    bat "dvrescue --version"
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
                        cleanWs( notFailBuild: true)
                    }
                }
            }
        }
        stage("Testing Install Package"){
            matrix{
                agent {
                    label CONFIGURATIONS[PLATFORM].agents.test.label
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
                            'ubuntu-18.04',
                            'visual-studio-2017-64bit',
                            'visual-studio-2019-32bit',
                            'visual-studio-2019-64bit',
                            )
                    }
                    axis {
                        name 'INSTALLER_PACKAGE'
                        values 'native-linux', 'MSI'
                    }


                }
                excludes {
                    exclude {
                        axis {
                            name 'INSTALLER_PACKAGE'
                            values 'native-linux'
                        }
                        axis {
                            name 'PLATFORM'
                            values(
                                'visual-studio-2017-64bit',
                                'visual-studio-2019-32bit',
                                'visual-studio-2019-64bit',
                                )
                        }
                    }
                    exclude {
                        axis {
                            name 'INSTALLER_PACKAGE'
                            values 'MSI'
                        }
                        axis {
                            name 'PLATFORM'
                            values(
                                'centos-7',
                                'centos-8',
                                'fedora-31',
                                'ubuntu-16.04',
                                'ubuntu-18.04',
                                )
                        }
                    }
                }
                stages {
                    stage("Install Package"){
                        options{
                             skipDefaultCheckout true
                        }
                        steps{
                            echo "installing"
                            unstash "${PLATFORM}-PACKAGE"
                            script{
                                def test_machine = docker.image(CONFIGURATIONS[PLATFORM].agents.test.dockerImage)
                                if(CONFIGURATIONS[PLATFORM].os_family == "windows"){
                                    test_machine.inside{
                                        powershell(script: CONFIGURATIONS[PLATFORM].agents.test.installCommand, label: "Installing ${PLATFORM} ${INSTALLER_PACKAGE}")
                                        bat(script: CONFIGURATIONS[PLATFORM].agents.test.runCommand, label: "Running dvrescue on ${PLATFORM}")
                                    }
                                }
                                if(CONFIGURATIONS[PLATFORM].os_family == "linux"){
                                    test_machine.inside("--user root") {
                                        if(PLATFORM.contains("ubuntu")){
                                            sh "apt update && apt-get install -y -f ./${findFiles(glob: '*.deb')[0]} | tee ${PLATFORM}-install.log"
                                        }

                                        if(PLATFORM.contains("fedora")){
                                            sh "dnf -y localinstall ./${findFiles(glob: '*.rpm')[0]} | tee ${PLATFORM}-install.log"
                                        }
                                        if(PLATFORM.contains("centos")){
                                            sh "yum -y update"
                                            sh "yum install -y epel-release"
                                            sh "yum -y localinstall ./${findFiles(glob: '*.rpm')[0]} | tee ${PLATFORM}-install.log"
                                        }
                                        sh "dvrescue --version"

                                    }
                                }
                            }
                        }
                        post{
                            always{
                                archiveArtifacts '*.log'
                            }
                            cleanup{
                                cleanWs( notFailBuild: true)
                            }
                        }
                    }
//                    stage("Install Linux Package"){
//                        options{
//                             skipDefaultCheckout true
//                        }
//                        when{
//                            expression {CONFIGURATIONS[PLATFORM].os_family == "linux"}
//                            beforeAgent true
//                        }
//                        steps{
//                            echo "Testing installing on ${PLATFORM}"
//                            script{
//                                def test_machine = docker.image(CONFIGURATIONS[PLATFORM].agents.test.dockerImage)
//                                unstash "${PLATFORM}-PACKAGE"
//                                test_machine.inside("--user root") {
//                                    if(PLATFORM.contains("ubuntu")){
//                                        sh "apt update && apt-get install -y -f ./${findFiles(glob: '*.deb')[0]}"
//                                    }
//
//                                    if(PLATFORM.contains("fedora")){
//                                        sh "dnf -y localinstall ./${findFiles(glob: '*.rpm')[0]}"
//                                    }
//                                    if(PLATFORM.contains("centos")){
//                                        sh "yum -y update"
//                                        sh "yum install -y epel-release"
//                                        sh "yum -y localinstall ./${findFiles(glob: '*.rpm')[0]}"
//                                    }
//                                    sh "dvrescue --version"
//
//                                }
//                            }
//                        }
//                        post{
//                            cleanup{
//                                cleanWs()
//                            }
//                        }
//                    }
//                    stage("Install MSI Package"){
//                        options{
//                              skipDefaultCheckout true
//                        }
//                        when{
//                            expression { CONFIGURATIONS[PLATFORM].os_family == "windows"}
//                            beforeAgent true
//                        }
//                        steps{
//                            echo "installing msi"
//                            unstash "${PLATFORM}-PACKAGE"
//                            script{
//                                def test_machine = docker.image(CONFIGURATIONS[PLATFORM].agents.test.dockerImage)
//                                test_machine.inside("--user ContainerAdministrator") {
//                                    try{
//                                        powershell "msiexec /i ${findFiles(glob: '*.msi')[0]} /qn /norestart /L*v! ${PLATFORM}-msiexec.log"
//                                        bat(script: CONFIGURATIONS[PLATFORM].agents.test.runCommand)
//                                    } catch( Exception e){
//                                        bat 'tree "C:\\Program Files" /A /F > %PLATFORM%-tree.log'
//                                        bat 'tree "C:\\Program Files (x86)" /A /F >> %PLATFORM%-tree.log'
//                                        error "${e}"
//                                    }
//                                }
//                            }
//                        }
//                        post{
//                            always{
//                                archiveArtifacts '*.log'
//                            }
//                            failure{
//
//                                archiveArtifacts '*tree.log'
//                            }
//                        }
//                    }
                }
            }
        }
    }
}
