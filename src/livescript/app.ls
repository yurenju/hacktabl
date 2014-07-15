#= require angular/angular.min.js
#= require app-controller.js
#= require app-template.js
#= require app-directive.js

angular.module 'app', <[
  app.controller
  app.template
  app.directive
]>
# Wake up user preference and sets user-id
.run <[UserPreference]> ++ !->