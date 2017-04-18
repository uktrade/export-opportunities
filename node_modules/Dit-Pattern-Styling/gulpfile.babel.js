// LIBRARIES
// - - - - - - - - - - - - - - -
import gulp from 'gulp';
import paths from './projectpath.babel';
import stylish from 'jshint-stylish';
import loadPlugins from 'gulp-load-plugins';

const plugins = loadPlugins();
// TASKS
// - - - - - - - - - - - - - - -

gulp.task('sass', () => gulp
    .src(paths.sass + '*.scss')
    .pipe(plugins.sass({
      outputStyle: 'compressed',
      includePaths: [
        require("bourbon-neat").includePaths
      ] 
    }))
    .pipe(gulp.dest(paths.public))
);


// Watch for changes and re-run tasks
gulp.task('watchForChanges', function() {
    gulp.watch(paths.sass + '**/*.scss', ['sass']);
});


gulp.task('lint:sass', () => gulp
    .src([
        paths.sass + '**/*.scss'
    ])
    .pipe(plugins.sassLint({
        rules: {
            'no-mergeable-selectors': 1, // Severity 1 (warning)
            'pseudo-element': 0,
            'no-ids': 0,
            'mixins-before-declarations': 0,
            'no-duplicate-properties': 0,
            'no-vendor-prefixes': 0,
            'single-line-per-selector': 0
        }
    }))
    .pipe(plugins.sassLint.format(stylish))
    .pipe(plugins.sassLint.failOnError())
);


gulp.task('lint',
    ['lint:sass']
);


// Default: compile everything
gulp.task('default',
    ['sass']
);

// Optional: recompile on changes
gulp.task('watch',
    ['watchForChanges']
);
