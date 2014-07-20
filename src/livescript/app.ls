#= require angular/angular.min.js
#= require app-controller.js
#= require app-template.js
#= require app-directive.js
#= require app-router.js

angular.module 'app', <[
  app.controller
  app.template
  app.directive
]>
# Wake up user preference and sets user-id
.run <[UserPreference]> ++ !->
# Redirect user to fepz if no path is specified
.run <[$location]> ++ ($location) !->
  $location.path \fepz