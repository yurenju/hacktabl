# Path configuration
#

const PATHS =
  JS: <[
      src/livescript/*.ls
      src/livescript/*.ls.ejs
      vendor/javascripts/*.ls
      vendor/bower_components/**/*.js
      !vendor/bower_components/angular-bootstrap/misc/*
      tmp/javascripts/**/*.js
    ]>
  HTML:
    TEMPLATES: <[src/jade/templates/*.jade]>
    ROOT: <[src/jade/*.jade]>
    BOOTSTRAP:
      modal: "vendor/bower_components/angular-bootstrap/template/modal/*.html"
      tooltip: "vendor/bower_components/angular-bootstrap/template/tooltip/*.html"
  CSS: <[
      src/sass/*.sass
    ]>


require! {
  connect
  gulp
  q
  'gulp-compass'
  'gulp-livereload'
  'gulp-filter'
  'gulp-uglify'
  'gulp-jade'
  'gulp-angular-templatecache'
  child_process.exec
  child_process.execFile
}

Sprocket = require 'sprocket'
Sprocket.viewLocals.isProduction = process.env.NODE_ENV is \production

environment = new Sprocket.Environment()

# Override Sprocket js engine because jshint throws error for no reason
#
environment.register-engine '.js', !(env, src, dest) ->
  if env.is-production
    filter = gulp-filter <[**/*.js !**/*.min.js]>
    src.pipe filter
       .pipe gulp-uglify!
       .on 'error', ->
          console.error "#{it.message} at #{it.file-name}##{it.line-number}"
          throw it
       .pipe filter.restore!
       .pipe dest
  else
    src.pipe dest
, mime_type: 'application/javascript'

# Override Sprocket html engine to bypass gulp-minify-htm
#
environment.registerEngine '.html', !(env, src, dest) ->
  src.pipe dest
, mime_type: 'text/html'


gulp.task \default, <[server]>

# Jade tempalte compilation
#
gulp.task \html, <[js css]>, ->
  gulp.src PATHS.HTML.ROOT
    .pipe environment.create-htmls-stream!
    .pipe gulp.dest './'

# Campaign template cache.
# All templates are collected into module "app.template".
#
gulp.task \template, ->
  gulp.src PATHS.HTML.TEMPLATES
  .pipe gulp-jade doctype: \html
  .pipe gulp-angular-templatecache 'app-template.js', do
    module: 'app.template'
    root: 'public/templates/'
    standalone: true
  .pipe gulp.dest 'tmp/javascripts'

# angular-ui-bootstrap selected template cache.
# All selected templates are collected into module "angular.template".
#
gulp.task \bootstrap-template, ->
  promises = for own let component, files of PATHS.HTML.BOOTSTRAP
    deferred = q.defer!

    gulp.src files
    .pipe gulp-angular-templatecache "angular-template-#{component}.js", do
      module: "angular.template.#{component}"
      root: "template/#{component}"
      standalone: true
    .pipe gulp.dest 'tmp/javascripts/angular-templates'
    .on \end, ->
      # console.log component, "template generated"
      deferred.resolve!

    deferred.promise

  return q.all(promises)

# Sass compilation using compass
#
gulp.task \compass, ->
  gulp.src PATHS.CSS
  .pipe gulp-compass do
    config_file: 'config/compass.rb'
    css: 'public/stylesheets'
    sass: 'src/sass'
  .on \error, (err) -> console.error err
  .pipe gulp.dest 'tmp/stylesheets/'

gulp.task \css, <[compass]> ->
  gulp.src 'tmp/stylesheets/*.css'
    .pipe environment.createStylesheetsStream()
    .pipe gulp.dest 'public/stylesheets/'

# Livescript compilation
#
gulp.task \js, <[bootstrap-template template]>, ->
  gulp.src PATHS.JS
  .pipe environment.createJavascriptsStream()
  .pipe gulp.dest 'public/javascripts/'

# Spin up a localhost server, default port = 5000
#
gulp.task \server, <[html]>, ->
  console.log 'Starting livereload server...'

  gulp.watch PATHS.CSS ++ PATHS.JS ++ PATHS.HTML.TEMPLATES ++ PATHS.HTML.ROOT, <[html]>

  gulp.watch <[index.html]>
      .on 'change', gulp-livereload.changed

  gulp-livereload.listen!

  console.log 'Starting connect server...'
  port = process.env.PORT || 3000

  connect!
  .use (req, res, next) !->
    # Rewrite to index.html if not from /public.
    req.url = '/index.html' unless req.url.match /^\/public\//
    next!
  .use connect.static('./')
  .listen port, ->
    console.log "Connect server starting at http://localhost:#port"
