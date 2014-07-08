#= require app-constant.js
#= require app-service.js

angular.module \app.controller, <[app.constant app.service]>
.controller \AppCtrl, <[
       EDIT_URL  MockData Spy  State
]> ++ (EDIT_URL, data,    Spy, State)!->
  @EDIT_URL = EDIT_URL
  data.then (d) ~>
    @data = d

  @Spy = Spy

  @State = State