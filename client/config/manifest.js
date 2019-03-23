'use strict';

module.exports = function(/* environment, appConfig */) {
  // See https://github.com/zonkyio/ember-web-app#documentation for a list of
  // supported properties

  return {
    name: "mirror",
    short_name: "mirror",
    description: "",
    start_url: "/",
    display: "standalone",
    background_color: "#fff",
    theme_color: "#fff",
    icons: [
      {
        src: '/img/mirror-logo.png',
        sizes: '200x200'
      },
      {
        src: '/img/mirror-logo-large.png',
        sizes: '512x512'
      },
    ],
    ms: {
      tileColor: '#fff'
    }
  };
}
