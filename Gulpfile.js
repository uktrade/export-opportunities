var gulp = require('gulp'),
    sass = require('gulp-sass'),
    sourcemaps = require('gulp-sourcemaps'),
    concat = require('gulp-concat'),
    uglify = require('gulp-uglify');

var includePaths = ['./vendor/assets/stylesheets/'];

gulp.task('compile-scss', () =>
  gulp.src('app/assets/stylesheets/new/**/*.scss')
    .pipe(sourcemaps.init())
    .pipe(sass({
      sourceComments: false,
      outputStyle: 'compressed',
      includePaths: includePaths
    }))
    .pipe(gulp.dest('public/stylesheets'))
);

gulp.task('scripts', function() {
  return gulp.src('app/assets/**/*.js')
    .pipe(concat('app.js'))
    .pipe(uglify())
    .pipe(gulp.dest('dist'));
});

gulp.task('default', ['compile-scss']);