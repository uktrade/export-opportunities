
(function () {
  var ssoCookieName = "sso_display_logged_in";
  var list = null;

function createEl(el, target){
  var ne = document.createElement(el);
  if( target )
     target.appendChild(ne);
  return ne;
 }

function createText(content, target){
  var ne = document.createTextNode(content);
  target.appendChild(ne);
  return ne;
}

function readCookie(name) {
  var cookies = {};
  if(cookies){ return cookies[name]; }

  var c = document.cookie.split('; ');

  for(var i=c.length-1; i>=0; i--){
    var C = c[i].split('=');
    cookies[C[0]] = C[1];
  }

  return cookies[name];
}

function addListItem (text, href, className) {
  var listItem = createEl('li');
  listItem.className = className;
  var anchor = createEl('a');
  anchor.href = href;
  anchor.className = className;
  var link = createText(text, anchor);
  listItem.appendChild(anchor);
  list.appendChild(listItem);
}

function setLoggedIn () {
  addProfile();
  addSignOut();
}

function setLoggedOut () {
  addRegister();
  addSignIn();
}

function addRegister () {
  addListItem ('Register', '#', 'anonymous');
}

function addSignIn () {
  addListItem ('Login', '#', 'anonymous signin');
}

function addProfile () {
  addListItem ('Profile', '#', 'profile');
}

function signOut () {
  addListItem ('Sign out', '#', 'signout');
}

function empty() {
  while (list.hasChildNodes()) {
    list.removeChild(list.firstChild);
  }
}

function setLoginStatus() {
  var cookieValue = readCookie(ssoCookieName);
  if (cookieValue == 'true') {
    setLoggedIn();
  } else {
    setLoggedOut();
  }
}

function init () {
  list = document.getElementsByClassName('account-links')[0];
  if (list) {
    empty();
    setLoginStatus();
  }
}

//init();

})();