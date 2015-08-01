require '../sass/app.sass'

require 'angular/angular.js'
require './app-controller'
require './app-directive'
require './app-router'

angular.module 'app', <[
  app.controller
  app.directive
]>

require 'ngtemplate?relativeTo=templates/&module=app!html!jade-html!../jade/templates/empty.jade'
