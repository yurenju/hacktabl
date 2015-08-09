#
# hacktabl has simple routing: /:etherpad-id
#
require 'angular-route/angular-route.js'

require('ngtemplate?relativeTo=templates/!html!jade-html!../jade/templates/app.jade')
require('ngtemplate?relativeTo=templates/!html!jade-html!../jade/templates/welcome.jade')

angular.module 'app.router', <[ngRoute]> .config <[
       $locationProvider  $routeProvider
]> ++ ($locationProvider, $routeProvider) !->

  $routeProvider
  .when '/:id', do
    templateUrl: 'app.jade'
    controller: 'AppCtrl as App'

  .when '/', do
    templateUrl: 'welcome.jade'

  $locationProvider.html5Mode do
    enabled: true
    requireBase: false
