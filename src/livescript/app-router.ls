#
# hacktabl has simple routing: /:etherpad-id
#
# No need for ui-router or ng-router.
#

angular.module 'app.router', []
.config <[$locationProvider]> ++ ($locationProvider) !->
  $locationProvider.html5Mode do
    enabled: true
    requireBase: false

# Provide the etherpad id constant from path,
# Remove the leading slash '/'
#
.factory \ETHERPAD_ID, <[$location]> ++ ($location) ->
  $location.path!slice(1)

# Default etherpad-id: fepz.
# Use $window.location to trigger page reload.
#
.run <[
       ETHERPAD_ID  $window
]> ++ (ETHERPAD_ID, $window) !->
  $window.location.href = "/fepz" if ETHERPAD_ID.length is 0