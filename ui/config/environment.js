/* jshint node: true */

module.exports = function(environment) {
  var ENV = {
    modulePrefix: 'mirror',
    podModulePrefix: 'mirror/pods',
    environment: environment,
    rootURL: '/',
    locationType: 'auto',
    EmberENV: {
      FEATURES: {
        // Here you can enable experimental features on an ember canary build
        // e.g. 'with-controller': true
      }
    },

    APP: {
      // Here you can pass flags/options to your application instance
      // when it is created
    },
    DS: {
      host: 'http://localhost:4000',
      wshost: 'ws://localhost:4000',
      namespace: 'api'
    },
    'ember-simple-auth': {
      authenticationRoute: 'auth.login',
      routeIfAlreadyAuthenticated: 'app.index',
      routeAfterAuthentication: 'app.index'
    },
    STATUS_CODES: {
      ok: 200,
      created: 201,
      unauthorized: 401,
      forbidden: 403,
      not_found: 404,
      unprocessable_entity: 422
    },
    ERROR_CODES: {
      not_found: {
        type: "404",
        description: "Page Not Found",
        message: "We're sorry... we searched all over but couldn't find the page you were looking for!"
      },
      server_error: {
        type: "500",
        description: "Something Went Wrong",
        message: "We're sorry... it seems like something strange is going on."
      },
      forbidden: {
        type: "403",
        description: "Forbidden",
        message: "That action is forbidden."
      },
      unauthorized: {
        type: "401",
        description: "Unauthorized",
        message: "That action is unauthorized."
      }
    },
    ERROR_MESSAGES: {
      generic: "Something Went Wrong"
    },
    SUCCESS_MESSAGES: {
      generic: "Success!"
    },
    CONFIRM_MESSAGES: {
      generic: "Please Confirm This Action"
    }
  };

  if (environment === 'development') {
    // ENV.APP.LOG_RESOLVER = true;
    // ENV.APP.LOG_ACTIVE_GENERATION = true;
    // ENV.APP.LOG_TRANSITIONS = true;
    // ENV.APP.LOG_TRANSITIONS_INTERNAL = true;
    // ENV.APP.LOG_VIEW_LOOKUPS = true;
  }

  if (environment === 'test') {
    // Testem prefers this...
    ENV.locationType = 'none';

    // keep test console output quieter
    ENV.APP.LOG_ACTIVE_GENERATION = false;
    ENV.APP.LOG_VIEW_LOOKUPS = false;

    ENV.APP.rootElement = '#ember-testing';
  }

  if (environment === 'production') {

  }

  return ENV;
};
