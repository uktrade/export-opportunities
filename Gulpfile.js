gulp.task('scss', () =>
  gulp.src('app/assets/stylesheets/**/*.scss')
    .pipe(sourceMaps.init())
    .pipe(sass({
      sourceComments: true,
      outputStyle: 'compressed'
    })).pipe(sourceMaps.write())
    .pipe(gulp.dest('public/stylesheets'))
    .pipe(liveReload())
);