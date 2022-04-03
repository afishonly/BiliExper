name: 'deploy_for_serverless'

on:
  watch:
    types: started
  workflow_dispatch:
    inputs:
      enc_server_disabled:
        description: '填1禁用心跳远程加密服务器(默认启用，不使用直播心跳请无视，需要注意启用状态下会上传直播心跳数据到第三方服务器)，不清楚请不要填写'
        required: false
        default: ''
      CRON:
        description: '指定cron定时表达式，默认每天中午12点启动脚本(注意腾讯云函数使用7位cron北京时间，阿里云函数使用6位cron UTC时间)，不清楚请不要填写'
        required: false
        default: ''
      REGION:
        description: '指定部署区域，腾讯云函数默认部署在  ap-guangzhou(广州)，阿里云函数默认部署在  cn-shanghai(上海)，不清楚请不要填写'
        required: false
        default: ''

jobs:
  deploy:
    runs-on: ubuntu-latest
    if: github.event_name == 'workflow_dispatch'
    steps:
    - uses: actions/checkout@v2
      with: 
        repository: ${{ secrets.REPOSITORY }}
        ref: ${{ secrets.REF }}
    
    - name: 执行部署脚本
      run: bash ./serverless/deploy.sh
      env:
          SERVERLESS_PLATFORM_VENDOR: tencent #serverless 境外默认为 aws，配置为腾讯
          TENCENT_SECRET_ID: ${{ secrets.TENCENT_SECRET_ID }}
          TENCENT_SECRET_KEY: ${{ secrets.TENCENT_SECRET_KEY }}
          ACCOUNT_ID: ${{ secrets.ACCOUNT_ID }}
          REGION: ${{ github.event.inputs.REGION }}
          ACCESS_KEY_ID: ${{ secrets.ACCESS_KEY_ID }}
          ACCESS_KEY_SECRET: ${{ secrets.ACCESS_KEY_SECRET }}
          TIMEOUT: 120
          CRON: ${{ github.event.inputs.CRON }}
          enc_server_disabled: ${{ github.event.inputs.enc_server_disabled }}
