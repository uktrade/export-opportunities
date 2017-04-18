var assert = require('assert');
var pathFormat = require('./index');

var winFormatTests = [
  [{ root: 'C:\\', dir: 'C:\\path\\dir', base: 'index.html', ext: '.html', name: 'index' }, 'C:\\path\\dir\\index.html'],
  [{ root: 'C:\\', dir: 'C:\\another_path\\DIR\\1\\2\\33', base: 'index', ext: '', name: 'index' }, 'C:\\another_path\\DIR\\1\\2\\33\\index'],
  [{ root: '', dir: 'another_path\\DIR with spaces\\1\\2\\33', base: 'index', ext: '', name: 'index' }, 'another_path\\DIR with spaces\\1\\2\\33\\index'],
  [{ root: '\\', dir: '\\foo', base: 'C:', ext: '', name: 'C:' }, '\\foo\\C:'],
  [{ root: '', dir: '', base: 'file', ext: '', name: 'file' }, 'file'],
  [{ root: '', dir: '.', base: 'file', ext: '', name: 'file' }, '.\\file'],

  // unc
  [{ root: '\\\\server\\share\\', dir: '\\\\server\\share\\', base: 'file_path', ext: '', name: 'file_path' }, '\\\\server\\share\\file_path'],
  [{ root: '\\\\server two\\shared folder\\', dir: '\\\\server two\\shared folder\\', base: 'file path.zip', ext: '.zip', name: 'file path' }, '\\\\server two\\shared folder\\file path.zip'],
  [{ root: '\\\\teela\\admin$\\', dir: '\\\\teela\\admin$\\', base: 'system32', ext: '', name: 'system32' }, '\\\\teela\\admin$\\system32'],
  [{ root: '\\\\?\\UNC\\', dir: '\\\\?\\UNC\\server', base: 'share', ext: '', name: 'share' }, '\\\\?\\UNC\\server\\share']
];

var winSpecialCaseFormatTests = [
  [{dir: 'some\\dir'}, 'some\\dir\\'],
  [{base: 'index.html'}, 'index.html'],
  [{}, '']
];

var unixFormatTests = [
  [{ root: '/', dir: '/home/user/dir', base: 'file.txt', ext: '.txt', name: 'file' }, '/home/user/dir/file.txt'],
  [{ root: '/', dir: '/home/user/a dir', base: 'another File.zip', ext: '.zip', name: 'another File' }, '/home/user/a dir/another File.zip'],
  [{ root: '/', dir: '/home/user/a dir/', base: 'another&File.', ext: '.', name: 'another&File' }, '/home/user/a dir//another&File.'],
  [{ root: '/', dir: '/home/user/a$$$dir/', base: 'another File.zip', ext: '.zip', name: 'another File' }, '/home/user/a$$$dir//another File.zip'],
  [{ root: '', dir: 'user/dir', base: 'another File.zip', ext: '.zip', name: 'another File' }, 'user/dir/another File.zip'],
  [{ root: '', dir: '', base: 'file', ext: '', name: 'file' }, 'file'],
  [{ root: '', dir: '', base: '.\\file', ext: '', name: '.\\file' }, '.\\file'],
  [{ root: '', dir: '.', base: 'file', ext: '', name: 'file' }, './file'],
  [{ root: '', dir: '', base: 'C:\\foo', ext: '', name: 'C:\\foo' }, 'C:\\foo']
];

var unixSpecialCaseFormatTests = [
  [{dir: 'some/dir'}, 'some/dir/'],
  [{base: 'index.html'}, 'index.html'],
  [{}, '']
];

var errors = [
  {input: null, message: /Parameter 'pathObject' must be an object, not/},
  {input: '', message: /Parameter 'pathObject' must be an object, not string/},
  {input: true, message: /Parameter 'pathObject' must be an object, not boolean/},
  {input: 1, message: /Parameter 'pathObject' must be an object, not number/},
  {input: undefined, message: /Parameter 'pathObject' must be an object, not undefined/},
];

checkFormat(pathFormat.win32, winFormatTests);
checkFormat(pathFormat.win32, winSpecialCaseFormatTests);

checkFormat(pathFormat.posix, unixFormatTests);
checkFormat(pathFormat.posix, unixSpecialCaseFormatTests);

checkErrors(pathFormat.win32);
checkErrors(pathFormat.posix);

function checkErrors(parse) {
  errors.forEach(function(errorCase) {
    try {
      parse(errorCase.input);
    } catch(err) {
      assert.ok(err instanceof TypeError);
      assert.ok(
        errorCase.message.test(err.message),
        'expected ' + errorCase.message + ' to match ' + err.message
      );
      return;
    }

    assert.fail('should have thrown');
  });
}

function checkFormat(format, testCases) {
  testCases.forEach(function(testCase) {
    assert.deepEqual(format(testCase[0]), testCase[1]);
  });
}
