module.exports = function() {
  let start = {
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
  };

  return start;
}