// main.bicep

@description('azd が自動で渡す環境名 (例: dev, prod)')
param environmentName string

@description('App Service の名前（ユニーク）')
param appName string = 'fastapi-echo-sample-sakamoto-hiroya'

// ← SKU を B1（Basic）に変更する
@description('App Service Plan SKU: Basic 以上で Always On が使えます')
param skuName string = 'B1'

@description('Python ランタイム バージョン')
param pythonVersion string = '3.9'

var location = resourceGroup().location

//──────────────────── App Service Plan ────────────────────
resource plan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: '${appName}-plan'
  location: location
  kind: 'linux'
  sku: {
    name: skuName       // B1
    tier: 'Basic'       // Basic プラン
  }
  properties: {
    reserved: true      // Linux プラン
  }
  tags: {
    'azd-env-name': environmentName
  }
}

//──────────────────── App Service (Web App) ───────────────
resource app 'Microsoft.Web/sites@2022-03-01' = {
  name: appName
  location: location
  kind: 'app,linux'
  properties: {
    serverFarmId: plan.id
    siteConfig: {
      linuxFxVersion: 'PYTHON|${pythonVersion}'
      appCommandLine: 'gunicorn -k uvicorn.workers.UvicornWorker main:app'
      // Always On を有効化
      alwaysOn: true
      // 起動待ちタイムアウトを延長（必要に応じて）
      containerStartTimeLimit: 600
    }
  }
  tags: {
    'azd-env-name':     environmentName
    'azd-service-name': 'api'
  }
}

output url string = 'https://${app.properties.defaultHostName}'