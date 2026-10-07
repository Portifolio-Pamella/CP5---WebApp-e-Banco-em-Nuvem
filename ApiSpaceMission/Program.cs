deploy:
runs - on: ubuntu - latest
    needs: build
    environment:
      name: 'Production'
      url: ${ { steps.deploy - to - webapp.outputs.webapp - url } }

steps:
-name: Download artifact from build job
        uses: actions / download - artifact@v4
        with:
          name: .net - app

      - name: 'Deploy to Azure Web App'
        id: deploy - to - webapp
        uses: azure / webapps - deploy@v3
        with:
          app - name: 'app-space-v2-rm565206'
          publish - profile: ${ { secrets.AZURE_WEBAPP_PUBLISH_PROFILE } }
package: '.'