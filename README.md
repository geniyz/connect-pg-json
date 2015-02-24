# Connect PostgreSQL

Connect-pg is a middleware session storage for the connect framework using 
PostgreSQL.  Why?  Because sometimes you need a relational database 
handling your data.  

## Requirements

* **Production**
	* *[connect](https://github.com/senchalabs/connect) 1.5.0 or later* The HTTP server framework used by Express.
	* *[pg](https://github.com/brianc/node-postgres) 0.50 or later* The node.js client for PostgreSQL.  
	* *[PostgreSQL](http://www.postgresql.org) 9.0 or later* The database.

##Feature List

* Create or update session information.
* Retreive information stored for the session.
* Delete the information for a session.
* Count the total number of active sessions.
* Delete all session information.
* Automatically delete session information that has expired.

## Installation 

1. **Setup PostgreSQL to Use Passwords to Log In**

	Refer to PostgreSQL's manual for changing the pg_hba.conf file.  The 
	database needs to be setup so that database users can log into the 
	system using a password.  

2. **Install the connect-pg library**

	*Standard Method:* npm install connect-pg
	
	*Manual Method:* [Download](https://github.com/jebas/connect-pg) the 
	files to your server.  The only file your script needs access to is 
	connect-pg.js found in the lib directory.  
	
3. **Install the SQL-Functions into DB**

	As the superuser for the database, install the sql-functions
	As shown in the following example:
	
	`psql -d {database name} -U postgres -f ./lib/web.sql`


## Usage

	* **In connect:**
		`connect.session( ({store: new (require('connect-pg-json'))(db.pgConnect), secret: 'tap-tap-tap'}) );`
		
	* **In Express:**
		`app.use(session({store: new (require('connect-pg-json'))(db.pgConnect), secret: 'tap-tap-tap'}))`

