/* create an administrator user. admin levels start at 100 (editor)
   and go to 500 (superuser). */
insert into users (uid,username, email, password, access, preamble) values (
 1,
 'pm', 
 'akrowne@vt.edu', 
 'r4d4r4', 
 500,
 '\\usepackage{amsmath}
\\usepackage{amsfonts}
\\usepackage{amssymb}');


/* default ACL setting for the above user -- world-readable */
insert into acl_default (userid, subjectid, _read, _write, _acl, user_or_group, 
 default_or_normal) values (1, 0, 1, 0, 0, 'u', 'd');

/* a silly default welcome news item */
insert into news (userid, title, intro) values (
 1,
 'Welcome to Noosphere!',
 'Welcome to Noosphere, a TeX-based collaborative knowledge-building framework!');

/* a LaTeX help forum */
insert into forums (uid, userid, title, data) values (
 1,
 1,
 'LaTeX Help Forum',
 'General LaTeX questions, and Noosphere LaTeX questions in specific.'
);

/* a system comments forum */ 
insert into forums (uid,userid, title, data) values (
 2,
 1,
 'Noosphere Help',  /* change this to your project name */
 'Help using this system.'
);

/* a system news forum */ 
insert into forums (uid,userid, title, data) values (
 3,
 1,
 'System News', 
 'System updates/changes not major enough for the front page.'
);
