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

## Popover, requires tooltip as its dependency
#= require angular-bootstrap/src/popover/popover.js

angular.module \ui.bootstrap.selected, <[
  angular.template.modal
  ui.bootstrap.modal

  angular.template.tooltip
  ui.bootstrap.tooltip

  angular.template.popover
  ui.bootstrap.popover
]>