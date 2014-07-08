#= require app-constant.js
#= require app-service.js

angular.module \app.controller, <[app.constant app.service]>
.controller \AppCtrl, <[
       EDIT_URL  MockData
]> ++ (EDIT_URL, data)!->
  @EDIT_URL = EDIT_URL
  data.then (d) ~>
    @data = d
