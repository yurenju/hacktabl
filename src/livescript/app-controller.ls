#= require app-constant.js

angular.module \app.controller, <[app.constant]>
.controller \AppCtrl, <[
       EDIT_URL
]> ++ (EDIT_URL)!->
  @msg = "It works!"
  @EDIT_URL = EDIT_URL
