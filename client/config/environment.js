'use strict';

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
      sticky_notes: {
        type_id: 1,
        states: ["start", "feedback", "sticky-notes.board-negative", "sticky-notes.board-positive", "score", "aggregate", "summary"],
        min_complete_state: 6,
        feedback: [
          {
            name: "negative",
            idPrefix: "went-poorly",
            label: "What could be improved?",
            type: "negative",
            value: ""
          },
          {
            name: "positive",
            idPrefix: "went-well",
            label: "What went well?",
            type: "positive",
            value: ""
          }
        ]
      }
    },
    stripe: {
      publishableKey: "pk_test_vd8mdRI6jcKLykIaVSgQCRwz"
    },
    DEMO: {
      user_feedback: [],
      user_score: [],
      team_members: [
        {
          id: 1,
          username: "Demo - YOU"
        },
        {
          id: 2,
          username: "Bobby Tables - Bot 1",
        },
        {
          id: 3,
          username: "R2-D2 - Bot 2",
        },
        {
          id: 4,
          username: "Skynet - Bot 3",
        }
      ],
      feedbacks: [
        {
          category: "good",
          message: "asdasda",
          user: {
            id: 3,
            username: "R2-D2 - Bot 2",
          },
          uuid: "abc123"
        }
      ],
      feedback_submissions: [
        {
          user: {
            id: 3,
            username: "R2-D2 - Bot 2",
          },
          submitted: true
        },
        {
          user: {
            id: 4,
            username: "Skynet - Bot 3",
          },
          submitted: true
        }
      ],
      score_submissions: [
        {
          user: {
            id: 3,
            username: "R2-D2 - Bot 2",
          },
          submitted: true
        },
        {
          user: {
            id: 4,
            username: "Skynet - Bot 3",
          },
          submitted: true
        }
      ],
      current_user: {
        id: 1,
        username: "Demo - YOU"
      },
      retrospectives: [
        {
          id: 1,
          name: "Demo Retrospective",
          state: 0,
          game: 1,
          participants: [
            {
              id: 1,
              username: "Demo - YOU"
            }
          ],
          moderator: {
            id: 1,
            username: "Demo - YOU"
          },
        },
        {
          id: 1,
          name: "Demo Retrospective",
          state: 1,
          game: 1,
          participants: [
            {
              id: 1,
              username: "Demo - YOU"
            },
            {
              id: 3,
              username: "R2-D2 - Bot 2",
            },
            {
              id: 4,
              username: "Skynet - Bot 3",
            }
          ],
          moderator: {
            id: 1,
            username: "Demo - YOU"
          },
          feedback_submissions: []
        },
        {
          id: 1,
          name: "Demo Retrospective",
          state: 2,
          game: 1,
          participants: [
            {
              id: 1,
              username: "Demo - YOU"
            },
            {
              id: 3,
              username: "R2-D2 - Bot 2",
            },
            {
              id: 4,
              username: "Skynet - Bot 3",
            }
          ],
          moderator: {
            id: 1,
            username: "Demo - YOU"
          },
          feedbacks: [
            {
              category: "negative",
              message: "Communication was lacking, so we ended up duplicating effort on a lot of things.",
              state: 1,
              user: {
                id: 3,
                username: "R2-D2 - Bot 2"
              }
            },
            {
              category: "negative",
              message: "I was very distracted by a bunch of things. People from other teams had a lot of questions, so I didn't feel like I was as useful to our team.",
              state: 0,
              user: {
                id: 3,
                username: "Skynet - Bot 3"
              }
            }
          ]
        },
        {
          id: 1,
          name: "Demo Retrospective",
          state: 3,
          game: 1,
          participants: [
            {
              id: 1,
              username: "Demo - YOU"
            },
            {
              id: 3,
              username: "R2-D2 - Bot 2",
            },
            {
              id: 4,
              username: "Skynet - Bot 3",
            }
          ],
          moderator: {
            id: 1,
            username: "Demo - YOU"
          },
          feedbacks: [
            {
              category: "positive",
              message: "We had fewer meetings, so I was able to focus more on getting work done.",
              state: 0,
              user: {
                id: 3,
                username: "R2-D2 - Bot 2"
              }
            },
            {
              category: "positive",
              message: "Although I was distracted by others from outside our group, I did make a lot of connections with other people that will probably be useful in the future.",
              state: 1,
              user: {
                id: 3,
                username: "Skynet - Bot 3"
              }
            }
          ],
        },
        {
          id: 1,
          name: "Demo Retrospective",
          state: 4,
          game: 1,
          participants: [
            {
              id: 1,
              username: "Demo - YOU"
            },
            {
              id: 3,
              username: "R2-D2 - Bot 2",
            },
            {
              id: 4,
              username: "Skynet - Bot 3",
            }
          ],
          moderator: {
            id: 1,
            username: "Demo - YOU"
          },
          score_submissions: []
        },
        {
          id: 1,
          name: "Demo Retrospective",
          state: 5,
          game: 1,
          participants: [
            {
              id: 1,
              username: "Demo - YOU"
            },
            {
              id: 3,
              username: "R2-D2 - Bot 2",
            },
            {
              id: 4,
              username: "Skynet - Bot 3",
            }
          ],
          moderator: {
            id: 1,
            username: "Demo - YOU"
          },
          scores: [
            {
              score: 8,
              user: {
                id: 4,
                username: "Skynet - Bot 3",
              }
            },
            {
              score: 7,
              user: {
                id: 3,
                username: "R2-D2 - Bot 2",
              }
            }
          ],
        },
        {
          id: 1,
          name: "Demo Retrospective",
          state: 6,
          game: 1,
          participants: [
            {
              id: 1,
              username: "Demo - YOU"
            },
            {
              id: 3,
              username: "R2-D2 - Bot 2",
            },
            {
              id: 4,
              username: "Skynet - Bot 3",
            }
          ],
          moderator: {
            id: 1,
            username: "Demo - YOU"
          }
        }
      ]
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
    ENV.APP.autoboot = false;
  }

  if (environment === 'production') {
    // here you can enable a production-specific feature
    ENV.DS.host = 'https://usemirror.io';
    ENV.DS.wshost = 'wss://usemirror.io';
  }

  return ENV;
};
