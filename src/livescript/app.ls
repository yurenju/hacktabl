require '../sass/app.sass'

require 'angular/angular.js'
require './app-controller'
require './app-directive'
require './app-router'

require 'ngtemplate?relativeTo=templates/!html!jade-html!../jade/templates/empty.jade'

angular.module 'app', <[
  app.controller
  app.directive
]>

