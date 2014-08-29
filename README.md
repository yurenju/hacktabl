hacktabl.org
================

Comparison table generator, using [Ethercalc](http://ethercalc.org) and Google Doc as the content backend.


Demo
----

### Basic usage

Example: [Doraemon compare table](http://hacktabl.org/doratable) or [FEPZ compare table](http://hacktabl.org/fepz).

* Multiple perspectives (Rows)
* Multiple positions (Columns)
* Showing references for each argument.
* Tooltips over words that needs further explanation.
* Use public Google Doc as the data source so that everyone can edit.


### Table view

Example: [FEPZ compare table for agricultire](http://hacktabl.org/fepz-agriculture)

* Show succinct summaries for each table cell so that the table gives a bigger picture for the issue.
* Clicking the table row toggles further arguments for that specific pespective.



Settings on EtherCalc
---------------------
You may change an existing hacktabl's URL from `http://hacktabl.org/<table-id>` to `http://hacktabl.org/<table-id>` to see the settings of the table. To create a new hacktabl, simply create a new spreadsheet with a desired table ID in EtherCalc.


### Required Settings

* `DOC_ID`: The ID of the Google Document that is used as the data source.
* `INFO_URL`: An url to a web page that provides further information for the readers. It will show up in a popup dialog when the user enters a hacktabl for the first time.

### Optional Settings

* `TYPE`: Whether or not to represent each cell with a short summary so that the entire table looks more succinct. Can be either empty or `TABLE`. For a running example, please refer to [FEPZ comparison table for education](http://hacktabl.org/fepz-edu) and [its settings on EtherCalc](http://ethercalc.org/fepz-edu).
* `HIGHLIGHT`: Whether or not to enable bold, italic and underlines. Can be either empty or `TRUE`. For a running example, please refer to [Copyright 2014](http://hacktabl.org/copyright2014) and [its settings on EtherCalc](http://ethercalc.org/copyright2014).


Development
-----------

After cloning the repository, please do the following in the repository folder:

```
npm install
npm install -g gulp
npm install -g LiveScript
gem install compass
```

Bower components are included in repository so there's no need to do `bower install`.

To start development server, please do:

```
gulp
```

When developing parsers, please run unit test using:

```
npm test
```
