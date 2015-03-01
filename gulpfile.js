var gulp = require('gulp');
var coffee = require('gulp-coffee');
var concat = require('gulp-concat');


gulp.task('coffee', function() {
  return gulp.src('./src/*.coffee')
    .pipe(coffee())
    .pipe(concat("route-51.js"))
    .pipe(gulp.dest('./dist/'))
});

gulp.task('build', ['coffee'], function () {
  return gulp.src([
    'bower_components/js-signals/dist/signals.min.js',
    'bower_components/hasher/dist/js/hasher.min.js',
    'bower_components/route-recognizer/dist/route-recognizer.js',
    'dist/route-51.js'
    ])
    .pipe(concat("route-51.bulk.js"))
    .pipe(gulp.dest('./dist/'));
});
