#
# Bring all files & modules required by specific angular-ui-bootstrap component
# together.
#
# Here we wrap the needed angular bootstrap modules and the template alltogether.
#
#= require_directory ../../tmp/javascripts/angular-templates

## Modal & dependencies
#= require angular-bootstrap/src/transition/transition.js
#= require ui-bootstrap-modal/index.js

## Tooltip & dependencies
#= require angular-bootstrap/src/position/position.js
#= require angular-bootstrap/src/bindHtml/bindHtml.js
#= require angular-bootstrap/src/tooltip/tooltip.js

## Dropdown, no templates!
#= require angular-bootstrap/src/dropdown/dropdown.js

angular.module \ui.bootstrap.selected, <[
  angular.template.modal
  ui.bootstrap.modal

  angular.template.tooltip
  ui.bootstrap.tooltip

  ui.bootstrap.dropdown
]>