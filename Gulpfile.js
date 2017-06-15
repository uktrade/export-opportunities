var gulp = require('gulp'),
    sass = require('gulp-sass'),
    sourcemaps = require('gulp-sourcemaps');

var includePaths = ['./vendor/assets/stylesheets/'];

gulp.task('compile-scss', () =>
  gulp.src('app/assets/stylesheets/**/*.scss')
    .pipe(sourcemaps.init())
    .pipe(sass({
      sourceComments: true,
      outputStyle: 'compressed',
      includePaths: includePaths
    })).pipe(sourceMaps.write())
    .pipe(gulp.dest('public/stylesheets'))
);

gulp.task('default', ['compile-scss']);