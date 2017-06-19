var publicAssets = "./public/assets";
var sourceFiles  = "./gulp/assets";

var gulp = require('gulp'),
    sass = require('gulp-sass'),
    sourcemaps = require('gulp-sourcemaps'),
    concat = require('gulp-concat'),
    uglify = require('gulp-uglify');

var includePaths = [
'./vendor/assets/stylesheets/',
'node_modules/normalize-scss/sass'];

gulp.task('compile-scss', () =>
  gulp.src(sourceFiles + '/stylesheets/**/*.scss')
    .pipe(sourcemaps.init())
    .pipe(sass({
      sourceComments: false,
      outputStyle: 'compressed',
      includePaths: includePaths
    }))
    .pipe(gulp.dest(publicAssets + '/stylesheets'))
);

gulp.task('scripts', function() {
  return gulp.src('app/assets/**/*.js')
    .pipe(concat('app.js'))
    .pipe(uglify())
    .pipe(gulp.dest('dist'));
});

gulp.task('default', ['compile-scss']);
gulp.task('build', ['compile-scss']);