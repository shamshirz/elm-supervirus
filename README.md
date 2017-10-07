# elm-webpack-starter


Slightly slimmer version of [elm-webpack-starter](https://github.com/elm-community/elm-webpack-starter)


### About:
A simple Webpack setup for writing [Elm](http://elm-lang.org/) apps:

* Dev server with live reloading, HMR
* Support for CSS/SCSS (with Autoprefixer), image assets
* Bundling and minification for deployment
* Basic app scaffold, using `Html.beginnerProgram`
* A snippet of example code to get you started!


### Do stuff

* Just once
  * `npm install -g elm elm-format yarn`
* Whenever you change a dependency
  * `npm run prep`
* When you're working
  * `npm start`
* Build a prod version (minified)
  * `npm run build`


### Tweaks to Original

* Add `prep`, remove the global uninstall/reinstall
  * Does yarn install and elm package install. Save the lock file
* Removed rimraf, bootstrap, jquery


### TODO

* Slim down the webpack config, confusingAF rn

