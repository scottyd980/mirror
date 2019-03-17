'use strict';

const demo = require('./demo/setup');
const tour = require('./demo/tour');
const sticky_notes = require('./games/sticky-notes');
const three_little_pigs = require('./games/three-little-pigs');

module.exports = function(environment) {
  let ENV = {
    modulePrefix: 'mirror',
    environment,
    rootURL: '/',
    locationType: 'auto',
    EmberENV: {
      FEATURES: {
        // Here you can enable experimental features on an ember canary build
        // e.g. 'with-controller': true
      },
      EXTEND_PROTOTYPES: {
        // Prevent Ember Data from overriding Date.parse.
        Date: false
      }
    },

    APP: {
      // Here you can pass flags/options to your application instance
      // when it is created
    },
    FLAGS: {
      billing: false,
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
    fontawesome: {
      defaultPrefix: 'fas' // light icons
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
      generic: "Something Went Wrong",
      time_out: "Connection Interruption",
      process: "Failed to Process Request",
      retrospective_in_progress: "Retrospective In Progress"
    },
    SUCCESS_MESSAGES: {
      generic: "Success!"
    },
    CONFIRM_MESSAGES: {
      generic: "Please Confirm This Action"
    },
    ACTIVE_BILLING_TYPES: [
      'active',
      'monthly',
      'yearly'
    ],
    retrospective: {
      sticky_notes: sticky_notes(),
      three_little_pigs: three_little_pigs()
    },
    stripe: {
      publishableKey: "***STRIPE_PUBLISHABLE_KEY***"
    },
    DEMO: demo(),
    DEMO_CONFIG: {
      base: demo(),
      state: null,
    },
    TOUR: tour(),
    metricsAdapters: [
      {
        name: 'GoogleAnalytics',
        environments: ['development', 'production'],
        config: {
          id: '***GOOGLE_ANALYTICS_KEY***',
          // Use `analytics_debug.js` in development
          debug: environment === 'development',
          // Use verbose tracing of GA events
          trace: environment === 'development',
          // Ensure development env hits aren't sent to GA
          sendHitTask: environment === 'production'
        }
      }
    ]
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
    ENV.APP.autoboot = false;

    ENV['ember-cli-mirage'] = {
      enabled: true
    };
  }

  if (environment === 'production') {
    // here you can enable a production-specific feature
    ENV.DS.host = '***HTTPS_HOST***'
    ENV.DS.wshost = '***WSS_HOST***'
  }

  return ENV;
};
