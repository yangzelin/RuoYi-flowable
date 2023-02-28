// 所有的脚本命令都放在pipeline 中
pipeline {
  // 指定任务在那个集群节点中执行
  agent any
  // 声明全局变量，方便后面使用
  environment {
     tag = tag.replaceFirst(/^.*\//, '')
     appName = 'flowable-admin'
     hostPort = '6080'
     containerPort = '8080'

     appUiName = 'flowable-ui'
     uiHostPort = '6000'
     uiContainerPort = '80'

     harborUser = 'admin'
     harborPassword = 'Harbor12345'
     harborRepo = 'yangzelin'
     gitToken = 'Jenkins_Publish'
     sonarqubeToken = 'squ_a2c90fa4c1c3d6bea64386433fb26395eb8e719f'
     dingDingWebHook = 'https://oapi.dingtalk.com/robot/send?access_token=d75d685d382897eee4629e33a5033ef0e4a439a95cddd268bd257d80d820f2e2'
//      hostPort = 'default' // 宿主机器端口
//      containerPort ='default' // 容器内部占用端口
  }


  stages {
    stage('拉取git仓库代码') {
      steps {
		checkout([
			$class: 'GitSCM',
			branches: [[name: '${tag}']],
			extensions: [],
			userRemoteConfigs: [[credentialsId: "${gitToken}", url: 'https://github.com/yangzelin/RuoYi-flowable.git']]
		])
      }
    }
	stage('通过maven构建项目') {
      steps {
        script {
          sh '''
             # 编译后端
             set MAVEN_OPTS=-Xms128m -Xmx512m
             /var/jenkins_home/maven/bin/mvn clean package -DskipTests -U
              # 编译前端
              cd ruoyi-ui
              export NODE_OPTIONS=--openssl-legacy-provider
              /var/jenkins_home/tools/jenkins.plugins.nodejs.tools.NodeJSInstallation/nodejs18.7.0/bin/npm install
              /var/jenkins_home/tools/jenkins.plugins.nodejs.tools.NodeJSInstallation/nodejs18.7.0/bin/npm run build:prod
          '''
        }
      }
    }
    stage('通过Docker制作自定义镜像') {
      steps {
        echo "制作后端镜像"
        sh '''cd ruoyi-admin
        docker build -t ${appName}:v1 -f Dockerfile ./
        '''
        echo "制作前端镜像"
        sh '''
         cd ruoyi-ui
         docker build -t ${appUiName}:${tag} -f dockerfile .
         docker image prune -f
         '''
      }
    }
    stage('将自定义镜像推送到Harbor') {
      steps {
        script {
        sh '''
          docker login -u ${harborUser} -p ${harborPassword} ${harborAddress}
          echo "推送后端镜像到Harbor仓库"
          docker tag ${appName}:${tag} ${harborAddress}/${harborRepo}/${appName}:${tag}
          docker push ${harborAddress}/${harborRepo}/${appName}:${tag}
            echo "推送前端镜像到Harbor仓库"
          docker tag ${appUiName}:${tag} ${harborAddress}/${harborRepo}/${appUiName}:${tag}
          docker push ${harborAddress}/${harborRepo}/${appUiName}:${tag}
         '''
        }
      }
    }
    stage('通过Publish Over SSH 通知目标服务器') {
      steps {
        script {
          echo "发布命令：/usr/local/test/deploy.sh $harborAddress $harborRepo ${appName} ${tag} ${hostPort} ${containerPort}"
          echo "发布命令：/usr/local/test/deploy.sh $harborAddress $harborRepo ${appUiName} ${tag} ${uiHostPort} ${uiContainerPort}"
          sshPublisher(publishers: [sshPublisherDesc(configName: 'test', transfers: [sshTransfer(cleanRemote: false, excludes: '', execCommand: '''/usr/local/test/deploy.sh $harborAddress $harborRepo ${appName} ${tag} ${hostPort} ${containerPort}
          /usr/local/test/deploy.sh $harborAddress $harborRepo ${appUiName} ${tag} ${uiHostPort} ${uiContainerPort}''', execTimeout: 120000, flatten: false, makeEmptyDirs: false, noDefaultExcludes: false, patternSeparator: '[, ]+', remoteDirectory: '', remoteDirectorySDF: false, removePrefix: '', sourceFiles: '')], usePromotionTimestamp: false, useWorkspaceInPromotion: false, verbose: false)])
        }

      }
    }
  }
}
