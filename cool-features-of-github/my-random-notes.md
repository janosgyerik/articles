Notepad
=======
A bunch of random (but useful!) notes you might keep in a plain txt file...


Java notes
------------
```
// where the hell my log4j settings come from??
System.out.println(Loader.getResource("log4j.properties"));
System.out.println(Loader.getResource("log4j.xml"));

// how much memory am I using?
System.out.println(Runtime.getRuntime().totalMemory() - Runtime.getRuntime().freeMemory());

// the name of the caller method was...?
Thread.currentThread().getStackTrace()[2]
```


Sybase notes
------------
```
-- all tables in the database
SELECT * FROM sysobjects WHERE type='U' order by name

-- all columns of a table
SELECT syscolumns.name, syscolumns.* 
FROM syscolumns JOIN sysobjects
       ON syscolumns.id=sysobjects.id
WHERE sysobjects.name='the_table'
```


MySQL notes
-----------
```
-- "create" a user in MySQL
GRANT ALL PRIVILEGES ON dbname.* TO 'dbuser'@localhost IDENTIFIED BY 'userpass';

-- Export data in CSV format
-- note: this requires the *FILE* permission
SELECT id, country FROM countries WHERE eutax = 1
INTO OUTFILE '/tmp/country.txt' FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n';
```


CSS notes
---------
```
/* CSS media query: apply if width < 980px */
@media (max-width: 980px) {
    body { padding-top: 0; }
}
```


Basic log4j.properties
----------------------
```
# Set root logger level to DEBUG and its only appender to A1.
log4j.rootLogger=DEBUG, A1

# A1 is set to be a ConsoleAppender.
log4j.appender.A1=org.apache.log4j.ConsoleAppender

# A1 uses PatternLayout.
log4j.appender.A1.layout=org.apache.log4j.PatternLayout
log4j.appender.A1.layout.ConversionPattern=%d{ISO8601} - %-5p %c{1} - %m%n
# 2012-05-18 15:58:39,210 - DEBUG CLASSNAME_WITHOUT_DOMAIN - LOGMESSAGE
```


