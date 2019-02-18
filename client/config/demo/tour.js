module.exports = function() {
  let tour = {
    start: [
      {
        id: 'tour-join',
        options: {
          attachTo: {
            element: '#tour-join',
            on: 'bottom'
          },
          buttons: [
            {
              classes: 'btn btn-default shepherd-button-secondary',
              text: 'Exit',
              type: 'cancel'
            },
            {
              classes: 'btn btn-info',
              text: 'Next',
              type: 'next'
            }
          ],
          title: "The Waiting Room",
          text: [
            "In the waiting room, you'll see a status indicator next to each person so you know who's here and who you're waiting on.",
            "For demo purposes, Bobby Tables can't make it, but we can still continue a retrospective even in the absence of some team members."
          ]
        }
      },
      {
        id: 'tour-moderator',
        options: {
          attachTo: {
            element: '#tour-moderator',
            on: 'bottom'
          },
          buttons: [
            {
              classes: 'btn btn-default shepherd-button-secondary',
              text: 'Exit',
              type: 'cancel'
            },
            {
              classes: 'btn btn-info',
              text: 'Back',
              type: 'back'
            },
            {
              classes: 'btn btn-info',
              text: 'Next',
              type: 'next'
            }
          ],
          title: "Moderating A Retrospective",
          text: [
            "In the demo, you're the retrospective moderator! The moderator is provided with a timer to help keep discussions under control.",
            "Others will not see the moderator actions like you do, however; they will still see everything else going on, in real-time.",
            "As you navigate through the retrospective, each member of the team will also be navigated to the correct page, too. This lets everyone stay on the same page about what is being discussed."
          ]
        }
      },
      {
        id: 'tour-cancel',
        options: {
          attachTo: {
            element: '#tour-cancel',
            on: 'bottom'
          },
          buttons: [
            {
              classes: 'btn btn-default shepherd-button-secondary',
              text: 'Exit',
              type: 'cancel'
            },
            {
              classes: 'btn btn-info',
              text: 'Back',
              type: 'back'
            },
            {
              classes: 'btn btn-info',
              text: 'Next',
              type: 'next'
            }
          ],
          title: "Canceling The Retrospective",
          text: [
            "If the retrospective was created by mistake, the moderator can cancel the retrospective. The moderator can do this at any point during the retrospective.",
            "In a real retrospective, this will return all members of the team back to the team dashboard."
          ]
        }
      },
      {
        id: 'tour-continue',
        options: {
          attachTo: {
            element: '#tour-continue',
            on: 'bottom'
          },
          buttons: [
            {
              classes: 'btn btn-default shepherd-button-secondary',
              text: 'Exit',
              type: 'cancel'
            },
            {
              classes: 'btn btn-info',
              text: 'Back',
              type: 'back'
            },
            {
              classes: 'btn btn-info',
              text: 'Close',
              type: 'cancel'
            }
          ],
          title: "Continuing The Retrospective",
          text: [
            "Since you are the moderator, once everyone is ready, you can continue on!"
          ]
        }
      }
    ],
    feedback: [
      {
        id: 'tour-feedback',
        options: {
          attachTo: {
            element: '#tour-feedback',
            on: 'bottom'
          },
          buttons: [
            {
              classes: 'btn btn-default shepherd-button-secondary',
              text: 'Exit',
              type: 'cancel'
            },
            {
              classes: 'btn btn-info',
              text: 'Next',
              type: 'next'
            }
          ],
          title: "Providing Feedback",
          text: [
            "Here, each team member enters feedback. Different games offer various types of feedback options."
          ]
        }
      },
      {
        id: 'tour-submit-feedback',
        options: {
          attachTo: {
            element: '#tour-submit-feedback',
            on: 'bottom'
          },
          buttons: [
            {
              classes: 'btn btn-default shepherd-button-secondary',
              text: 'Exit',
              type: 'cancel'
            },
            {
              classes: 'btn btn-info',
              text: 'Back',
              type: 'back'
            },
            {
              classes: 'btn btn-info',
              text: 'Next',
              type: 'next'
            }
          ],
          title: "Submitting Feedback",
          text: [
            "Once you've finished entering your feedback, click this button to submit your feedback and notify others that you've submitted."
          ]
        }
      },
      {
        id: 'tour-feedback-participants',
        options: {
          attachTo: {
            element: '#tour-feedback-participants',
            on: 'bottom'
          },
          buttons: [
            {
              classes: 'btn btn-default shepherd-button-secondary',
              text: 'Exit',
              type: 'cancel'
            },
            {
              classes: 'btn btn-info',
              text: 'Back',
              type: 'back'
            },
            {
              classes: 'btn btn-info',
              text: 'Next',
              type: 'next'
            }
          ],
          title: "Participant Status",
          text: [
            "We keep you informed of who has submitted their feedback already and who is still working."
          ]
        }
      },
      {
        id: 'tour-feedback-back',
        options: {
          attachTo: {
            element: '#tour-feedback-back',
            on: 'bottom'
          },
          buttons: [
            {
              classes: 'btn btn-default shepherd-button-secondary',
              text: 'Exit',
              type: 'cancel'
            },
            {
              classes: 'btn btn-info',
              text: 'Back',
              type: 'back'
            },
            {
              classes: 'btn btn-info',
              text: 'Next',
              type: 'next'
            }
          ],
          title: "Navigation Options",
          text: [
            "Now that we're in the retrospective, you also have the ability to go back to the previous step. Similar to the rest of the retrospective, all team members will navigate with you."
          ]
        }
      },
      {
        id: 'tour-feedback-continue',
        options: {
          attachTo: {
            element: '#tour-feedback-continue',
            on: 'bottom'
          },
          buttons: [
            {
              classes: 'btn btn-default shepherd-button-secondary',
              text: 'Exit',
              type: 'cancel'
            },
            {
              classes: 'btn btn-info',
              text: 'Back',
              type: 'back'
            },
            {
              classes: 'btn btn-info',
              text: 'Close',
              type: 'next'
            }
          ],
          title: "Continuing The Retrospective",
          text: [
            "Once you've entered your feedback, let's move on to the next step."
          ]
        }
      }
    ],
    negative: [
      {
        id: 'tour-card',
        options: {
          attachTo: {
            element: '#tour-card',
            on: 'bottom'
          },
          buttons: [
            {
              classes: 'btn btn-default shepherd-button-secondary',
              text: 'Exit',
              type: 'cancel'
            },
            {
              classes: 'btn btn-info',
              text: 'Next',
              type: 'next'
            }
          ],
          title: "Reviewing Feedback",
          text: [
            "For each item that was entered as feedback by your team, you can review them here. In this game, we first go over what can be improved, while on the next step we'll review what went well."
          ]
        }
      },
      {
        id: 'tour-card-navigation',
        options: {
          attachTo: {
            element: '#tour-card .note--actions--navigation',
            on: 'bottom'
          },
          buttons: [
            {
              classes: 'btn btn-default shepherd-button-secondary',
              text: 'Exit',
              type: 'cancel'
            },
            {
              classes: 'btn btn-info',
              text: 'Back',
              type: 'back'
            },
            {
              classes: 'btn btn-info',
              text: 'Next',
              type: 'next'
            }
          ],
          title: "Navigating Feedback",
          text: [
            "Since you're the moderator, you see the previous and next actions, to let you cycle through the feedback provided and discuss each one."
          ]
        }
      },
      {
        id: 'tour-card-flag',
        options: {
          attachTo: {
            element: '#tour-card .note--actions--flag',
            on: 'bottom'
          },
          buttons: [
            {
              classes: 'btn btn-default shepherd-button-secondary',
              text: 'Exit',
              type: 'cancel'
            },
            {
              classes: 'btn btn-info',
              text: 'Back',
              type: 'back'
            },
            {
              classes: 'btn btn-info',
              text: 'Next',
              type: 'next'
            }
          ],
          title: "Taking Action",
          text: [
            "As the moderator, you also have the ability to flag any of the feedback items. This can be used to make a note of any action the team plans on taking to resolve issues or make things better."
          ]
        }
      },
      {
        id: 'tour-continue',
        options: {
          attachTo: {
            element: '#tour-continue',
            on: 'bottom'
          },
          buttons: [
            {
              classes: 'btn btn-default shepherd-button-secondary',
              text: 'Exit',
              type: 'cancel'
            },
            {
              classes: 'btn btn-info',
              text: 'Back',
              type: 'back'
            },
            {
              classes: 'btn btn-info',
              text: 'Close',
              type: 'next'
            }
          ],
          title: "Continuing The Retrospective",
          text: [
            "Once you've discussed everything that your team thinks needs improvement, let's move on to what they think went well."
          ]
        }
      }
    ],
    positive: [
      {
        id: 'tour-card',
        options: {
          attachTo: {
            element: '#tour-card',
            on: 'bottom'
          },
          buttons: [
            {
              classes: 'btn btn-default shepherd-button-secondary',
              text: 'Exit',
              type: 'cancel'
            },
            {
              classes: 'btn btn-info',
              text: 'Next',
              type: 'next'
            }
          ],
          title: "Reviewing Feedback",
          text: [
            "You'll notice this is a very similar look and feel to the last step, but this step is meant for discussing what went well."
          ]
        }
      },
      {
        id: 'tour-continue',
        options: {
          attachTo: {
            element: '#tour-continue',
            on: 'bottom'
          },
          buttons: [
            {
              classes: 'btn btn-default shepherd-button-secondary',
              text: 'Exit',
              type: 'cancel'
            },
            {
              classes: 'btn btn-info',
              text: 'Back',
              type: 'back'
            },
            {
              classes: 'btn btn-info',
              text: 'Close',
              type: 'next'
            }
          ],
          title: "Continuing The Retrospective",
          text: [
            "Now that we've discussed all the feedback, let's score how well we think the sprint went."
          ]
        }
      }
    ],
    score: [
      {
        id: 'tour-score',
        options: {
          attachTo: {
            element: '#tour-score',
            on: 'bottom'
          },
          buttons: [
            {
              classes: 'btn btn-default shepherd-button-secondary',
              text: 'Exit',
              type: 'cancel'
            },
            {
              classes: 'btn btn-info',
              text: 'Next',
              type: 'next'
            }
          ],
          title: "Scoring The Sprint",
          text: [
            "Your team can decide what factors into this score, but in general, you should provide a score based on your interpretation of how well the team is doing.",
            "Again, once you select a score, submit it to let others know you're ready to move on."
          ]
        }
      },
      {
        id: 'tour-continue',
        options: {
          attachTo: {
            element: '#tour-continue',
            on: 'bottom'
          },
          buttons: [
            {
              classes: 'btn btn-default shepherd-button-secondary',
              text: 'Exit',
              type: 'cancel'
            },
            {
              classes: 'btn btn-info',
              text: 'Back',
              type: 'back'
            },
            {
              classes: 'btn btn-info',
              text: 'Close',
              type: 'next'
            }
          ],
          title: "Continuing The Retrospective",
          text: [
            "Now that everyone has provided a score, let's go see what the general sentiment about the team is."
          ]
        }
      }
    ],
    aggregate: [
      {
        id: 'tour-aggregate',
        options: {
          attachTo: {
            element: '#tour-aggregate',
            on: 'bottom'
          },
          buttons: [
            {
              classes: 'btn btn-default shepherd-button-secondary',
              text: 'Exit',
              type: 'cancel'
            },
            {
              classes: 'btn btn-info',
              text: 'Next',
              type: 'next'
            }
          ],
          title: "Scoring The Sprint",
          text: [
            "Mirror shows everyone what the high, low, and average scores provided were.",
            "This can help drive further discussion, as your team likely wants to be on a steadily increasing or stable path. You can also look for outliers and to try and determine if and why someone isn't happy."
          ]
        }
      },
      {
        id: 'tour-continue',
        options: {
          attachTo: {
            element: '#tour-continue',
            on: 'bottom'
          },
          buttons: [
            {
              classes: 'btn btn-default shepherd-button-secondary',
              text: 'Exit',
              type: 'cancel'
            },
            {
              classes: 'btn btn-info',
              text: 'Back',
              type: 'back'
            },
            {
              classes: 'btn btn-info',
              text: 'Close',
              type: 'next'
            }
          ],
          title: "View A Summary",
          text: [
            "Now that the retrospective is over, you can go review a summary of everything that went on."
          ]
        }
      }
    ],
    summary: [
      {
        id: 'tour-summary',
        options: {
          buttons: [
            {
              classes: 'btn btn-default shepherd-button-secondary',
              text: 'Exit',
              type: 'cancel'
            },
            {
              classes: 'btn btn-info',
              text: 'Next',
              type: 'next'
            }
          ],
          title: "Retrospective Summary",
          text: [
            "You'll notice that everything that was in the sprint is now aggregated on the summary page.",
            "This summary page is kept in your team's history, so you'll always have a way to go back and find any feedback that was provided during the retrospective."
          ]
        }
      },
      {
        id: 'tour-continue',
        options: {
          attachTo: {
            element: '#tour-continue',
            on: 'bottom'
          },
          buttons: [
            {
              classes: 'btn btn-default shepherd-button-secondary',
              text: 'Exit',
              type: 'cancel'
            },
            {
              classes: 'btn btn-info',
              text: 'Back',
              type: 'back'
            },
            {
              classes: 'btn btn-info',
              text: 'Close',
              type: 'next'
            }
          ],
          title: "Demo Complete",
          text: [
            "The demo is now complete. This will take you back to the home page. We hope this has been helpful, and we hope you'll take advantage of Mirror for real retrospectives!"
          ]
        }
      }
    ]
  };

  return tour;
};