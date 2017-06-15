var gulp = require('gulp'),
    sass = require('gulp-sass'),
    sourcemaps = require('gulp-sourcemaps');

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

gulp.task('default', ['compile-scss']);