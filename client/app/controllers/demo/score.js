import { later } from '@ember/runloop';
import ENV from 'mirror/config/environment';
import RetrospectiveController from 'mirror/controllers/demo/extends/retrospective';
import $ from 'jquery';

export default RetrospectiveController.extend({
  submitted: false,
  showModal: false,

  init() {
    this._super(...arguments);
    this.begin_score();
  },

  begin_score: function() {
    later(this, function() {
      this.get('model.scoreSubmissions').pushObject(ENV.DEMO.score_submissions[0]);
      later(this, function() {
        this.get('model.scoreSubmissions').pushObject(ENV.DEMO.score_submissions[1]);
      }, 900);
    }, 500);
  },

  start_tour() {
    const tour = this.get('tour');
    tour.addSteps([
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
    ]);
    later(this, function() {
      tour.start();
    }, 100);
  },

  actions: {
    close: function() {
      $('.tippy-popper').show();
      this.set('showModal', false);
    },
    start: function() {
      this.begin_joining();
      this.send('close');
    },
    submit: function() {
      const sprintScore = $('input[name="sprintScore"]:checked').val();
      console.log(sprintScore);
    
      if (typeof sprintScore !== "undefined") {
        this.get('model.scoreSubmissions').pushObject({
          user: ENV.DEMO.current_user,
          submitted: true
        });
  
        ENV.DEMO.user_score.pushObject({
          score: parseInt(sprintScore),
          user: ENV.DEMO.current_user
        })

        this.set('submitted', true);
      } else {
        $('.tippy-popper').hide();
        this.set('showModal', true);
      }
    }
  }
});