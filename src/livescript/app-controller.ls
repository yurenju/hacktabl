#= require app-constant.js
#= require app-service.js

angular.module \app.controller, <[app.constant app.service]>
.controller \AppCtrl, <[
       EDIT_URL  MockData Spy
]> ++ (EDIT_URL, data,    Spy)!->
  @EDIT_URL = EDIT_URL
  data.then (d) ~>
    @data = d

  @Spy = Spy