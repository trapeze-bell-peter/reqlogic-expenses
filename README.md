# Rails 5, Webpacker, Stimulus.js 1 and Bootstrap 4: a winning combination?

## Motivation
This project is really a sandbox for me to explore how best to deliver a Rails
5 app using Stimulus and Bootstrap 4.

## The Sandbox Application
The application itself is an app that allows TGUK staff to enter their expenses.
Our expenses submission system (called ReqLogic) has a poor user interface.  It
does have one redeeming feature: it is possible to create an Excel spreadsheet
for import into the system.  However, that spreadsheet must be absolutely
correctly formatted or it is rejected.  Unfortunately, the error messages that
ReqLogic produces are useless.

So this app gives staff a means to efficiently enter expenses, save them,
and then download them as an Excel file for import into ReqLogic.

Key features of the app are: expense entry lines can be inserted at random
points, lines can be copied, and lines can be dragged and dropped to re-arrange.

Future planned features will include ability to copy expenses lines from previous
submissions, and the ability to save images with each expense line.

## What I was testing and found

* Replacing Sprockets entirely with Webpacker.  Rails 5.2 makes this much
  easier.  This has worked well, and is useful.  No need to try and find 
  a packaged Gem of your favourite JS plugin, simply add it to the 
  package.json file, run Yarn and Webpacker does the rest.  This is how
  I added Bootstrap 4.3 into the app.
* Avoid the need for complex Javascript frameworks as a frontend.  Instead
  add a few key data tags onto the HTML page, and create a few Controller
  classes.  Stimulus.js does the rest. On the whole, this works well.  I
  prefer how I can use data tags in the HTML to link content to controllers,
  when compared to JQuery.  More later.
  

## Key lessons about using Stimulus.js

