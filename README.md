# React.js/Redux Workshops - Conference Management Tool

This is an application which is a starting point for fiddling with React.js and Redux together on the workshop. Just clone/fork this repository and start working!

## Requirements:

* PostgreSQL (tested on 9.5.1 - needs to have `pg_crypto` extension available)
* ExecJS adapter - recommended [Node.js](https://nodejs.org/en/)
* Ruby installed. At least 1.9 is required. An author used Ruby 2.2.0.

## Usage:

This application is an API for the frontend application you'll be creating. It consists of:

* API endpoints with responses formatted in the JSON API fashion. It follows the limited [HATEOAS](https://en.wikipedia.org/wiki/HATEOAS) principle, so you should be able to discover all API endpoints by examining the root route.
* Very simple HTML scaffolds to have something to start with. Only dummy data, they're not connected with backend at all.
* A ready environment with [Redux](https://github.com/reactjs/redux), [React.js](https://github.com/facebook/react), [React-Bootstrap](https://react-bootstrap.github.io/), [classNames](https://github.com/JedWatson/classnames), [uuid-js](https://github.com/pnegri/uuid-js) and [React-Redux](https://github.com/reactjs/react-redux) installed. You can use ECMAScript 2015 in this environment. Modules are not supported (yet!), so no `import`/`export` statements.
* A set of tiny utilities to make your life way easier - [`fetch`](https://fetch.spec.whatwg.org/)-based adapter for hitting JSON API endpoints and small utility to structure your reducers prettier than one-big-switch.

To get started with discovering backend, you should GET the root path and follow `links`. Try `GET`/`POST` requests on them to check which options are available. If stuck, consult the documents with Q&A and examples.

## Goal:

Your goal is to create a working frontend for the conference management app. Following user stories are possible to implement with this API:

* An user can list conferences.
* An user can create a conference by providing its name and unique identifier (UUID-based).
* An user can delete a conference.
* An user can create a conference day.
* An user can accept an event to be hosted on a conference, providing its name, host, description and time in minutes.
* An user can remove accepted event from conference.
* An user can plan an event for a given conference day by giving a start day within date.

There are (very) basic HTML mockups for some actions. There is also [Bootstrap](http://getbootstrap.com/) installed so you can use it to extend/modify those views. **I recommend to experiment with your UI solutions - you can do better than reimplementing static views! :)**.

## Test usage:

We've tried to implement tests in an actor-based manner. You can find them on `test/integration`. It consists of testing app by hitting API endpoints - exactly like you'll be doing. They can be very insightful if you are stuck, so we recommend to take a look at them.

## Setup:

```
git clone https://github.com/arkency/react-workshops-2016-wrocloverb.git
cd react-workshops-2016-wrocloverb
bundle install
bundle exec rake db:create
bundle exec rake db:schema:load
bundle exec rake db:seed
bundle exec rake db:test:prepare

# optional: run tests to check if everything works fine. They should be green!
bundle exec rake test
```

## How to run?

```
cd react-workshops-2016-wrocloverb
bundle exec rails s
```

## Docs:

* [React.js](http://facebook.github.io/react/)
* [Redux](http://redux.js.org/docs/introduction/index.html)
* [React-Redux](http://redux.js.org/docs/basics/UsageWithReact.html)
* [classNames](http://jedwatson.github.io/classnames/)
* [React-Bootstrap](https://react-bootstrap.github.io/)
* [uuid-js](https://github.com/pnegri/uuid-js#functions-list)

## Need a gentlier start?

If you need a gentlier start, be sure to read workshop slides. There is also a Q&A document available for workshop attendants.

Apart from this, there are some materials you may find useful:

* [Getting started with Redux (videos)](https://egghead.io/series/getting-started-with-redux) for learning about Redux
* [React.js Koans](https://github.com/arkency/reactjs_koans) for learning basics of React.js
* [ECMAScript 6 Katas](http://es6katas.org/) for modern JavaScript language proficiency

## Credits

<img src="http://arkency.com/images/arkency.png" alt="Arkency" width="14%" align="left" />

This workshop is hosted by [Arkency](http://arkency.com). We'd like to invite you to [read our Rails-related blog](http://blog.arkency.com). There is also a [React Kung Fu](http://reactkungfu.com/) initiative which is focused around React.js. 

You can contact us [by an e-mail](mailto:dev@arkency.com) or [tweet something to us](https://twitter.com/arkency). Good luck!
