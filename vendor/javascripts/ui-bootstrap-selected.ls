#
# Bring all files & modules required by specific angular-ui-bootstrap component
# together.
#

## Modal & dependencies
require 'angular-bootstrap/src/transition/transition.js'
require 'ui-bootstrap-modal/index.js'

require 'ngtemplate?relativeTo=/angular-bootstrap/!html!../bower_components/angular-bootstrap/template/modal/window.html'
require 'ngtemplate?relativeTo=/angular-bootstrap/!html!../bower_components/angular-bootstrap/template/modal/backdrop.html'

## Tooltip & dependencies
require 'angular-bootstrap/src/position/position.js'
require 'angular-bootstrap/src/bindHtml/bindHtml.js'
require 'angular-bootstrap/src/tooltip/tooltip.js'

require 'ngtemplate?relativeTo=angular-bootstrap/!html!../bower_components/angular-bootstrap/template/tooltip/tooltip-popup.html'
require 'ngtemplate?relativeTo=angular-bootstrap/!html!../bower_components/angular-bootstrap/template/tooltip/tooltip-html-unsafe-popup.html'

## Dropdown, no templates!
require 'angular-bootstrap/src/dropdown/dropdown.js'

angular.module \ui.bootstrap.selected, <[
  ui.bootstrap.modal
  ui.bootstrap.tooltip
  ui.bootstrap.dropdown
]>
