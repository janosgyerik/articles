GitHub Flavored Markdown (GFM)
==============================
Some examples that are not part of "standard" markdown but you can do with GFM.


Fenced code blocks
------------------
```
// where the hell my log4j settings come from??
System.out.println(Loader.getResource("log4j.properties"));
System.out.println(Loader.getResource("log4j.xml"));

-- all tables in the database
SELECT * FROM sysobjects WHERE type='U' order by name

/* CSS media query: apply if width < 980px */
@media (max-width: 980px) {
    body { padding-top: 0; }
}
```


Syntax highlighting
-------------------
```java
// where the hell my log4j settings come from??
System.out.println(Loader.getResource("log4j.properties"));
System.out.println(Loader.getResource("log4j.xml"));
```

```sql
-- all tables in the database
SELECT * FROM sysobjects WHERE type='U' order by name
```

```css
/* CSS media query: apply if width < 980px */
@media (max-width: 980px) {
    body { padding-top: 0; }
}
```


...and more...
--------------
See https://help.github.com/articles/github-flavored-markdown
(Yeah btw URLs are autolinked, no need to use the verbose syntax of "standard" markdown.)
