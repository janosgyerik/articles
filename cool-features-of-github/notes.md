Cool features of GitHub
-----------------------
*(Even if you don't use Git...yet)*

0. create gists
0. embed gists
0. repo in an instance
0. Wiki
0. In-browser editing
0. issue tracking even for projects NOT on github
0. gh-pages
0. OpenID
0. Cloud 9
0. code reviews


## Story

- this is not about git, this is about github
- what is git anyway? -- container of source code = repository
- what is github anyway? -- container of git repositories
- git != github
- github is primarily for git repositories
- github also has lots of cool extra stuff -- this talk
- gists -- short code
- gists -- random note
- gists -- cool french phrases...
- create a gist -- filename or language -- syntax highlighting
- history of a gist
- link to a gist
- embed a gist -- pretty
- clone a gist
- create a repository
- edit files online
- markdown syntax
- github flavored markdown
- clone repository
- edit files locally
- create a wiki
- use your favorite wikitext
- export a wiki
- gh-pages -- static html hosting
- github is popular
- github is huge
- github is robust


## Gists

- Code snippets
- Random notes
- Syntax highlighting
- Version controlled
- Clone-able


## Embed Gists

- Syntax highlighting


## ? wiki / repo


## Hidden features

- Add `?w=1` to any diff url to ignore whitespace
- Every Git repository is also a Subversion repository

        svn co https://github.com/USER/REPO

- Can commit and bypass corporate firewall???

    See: https://github.com/janosgyerik/articles.git

- Shortcuts

        - `t`: activate file finder
        - `w`: branch selector
        - `s`: quick search

- GitHub flavored markdown

        ```ruby
        require 'redcarpet'
        markdown = Redcarpet.new("Heya")
        puts markdown.to_html
        ```

- Commits by author, append to url: `?author=holman`

- EMOJI! :+1: :-1: :HEART: :FIRE: :RAGE2: :SHIT: :SHIPIT:

- Line linking, append to url: `#L16`, `#L16-19`

- `/usr/repo/compare/master...mybranch`

- `/usr/repo/compare/master@{1.day.ago}...master`

- `/usr/repo/compare/master@{yesterday}...master`

- `/usr/repo/compare/master@{2012-02-25}...master`

- Staging hunks: `git add -p`

- Last matched commit search: `git show :/query`

- `git checkout -` ... like `cd -`

- `git branch --merged`

- `git branch --no-merged`

- Commits in AA that aren't in BB:

        git log AA ^BB

- Lost commits: `git fsck --lost-found`


## Stats as of 2012 August

- Since 2008

- 1.9m users

- 6.5m repositories

- 22 fileserver pairs, adding 2tb a month, 23tb of repo data

- Jan 2008 -- 0

- Dec 2008 -- 42k users, 80k repos

- 2010 -- 166k users, 484k repos

- 2011 -- 510k users, 1.3m repos

- 2012 -- 1.2m users, 3.4m repos

- Aug 2012 -- 1.9m users, 6.5m repos

- github deploys 20-40 times a day

- complete unit tests run in about 200 seconds

- 5 years, 0 employees have quit, 108 employees

- stable = deploy constantly



## Resources

- https://speakerdeck.com/holman/git-and-github-secrets
- https://speakerdeck.com/holman/how-to-build-a-github
- https://speakerdeck.com/holman/scaling-github
- https://speakerdeck.com/holman/how-github-uses-github-to-build-github
- https://code.google.com/apis/ajax/playground/?type=visualization#area_chart
