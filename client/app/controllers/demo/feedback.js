import { later } from '@ember/runloop';
import ENV from 'mirror/config/environment';
import RetrospectiveController from 'mirror/controllers/demo/extends/retrospective';
import $ from 'jquery';

export default RetrospectiveController.extend({
  submitted: false,
  showModal: false,

  init() {
    this._super(...arguments);
    this.begin_feedback();
  },

  begin_feedback: function() {
    later(this, function() {
      this.get('model.feedbackSubmissions').pushObject(ENV.DEMO.feedback_submissions[0]);
      later(this, function() {
        this.get('model.feedbackSubmissions').pushObject(ENV.DEMO.feedback_submissions[1]);
      }, 800);
    }, 1400);
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
            "During this step, each team member enters feedback. Different games offer different types of feedback options."
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
      const feedbackExists = this.get('model').gameInput.some((feedback) => {
        return (feedback.value.trim() !== "") ? true : false;
      });

      if(feedbackExists) {
        this.get('model.feedbackSubmissions').pushObject({
          user: ENV.DEMO.current_user,
          submitted: true
        });
        this.get('model').gameInput.forEach((feedback) => {
          ENV.DEMO.user_feedback.pushObject({
            category: feedback.type,
            message: feedback.value,
            user: ENV.DEMO.current_user
          })
        });
        this.set('submitted', true);
      } else {
        $('.tippy-popper').hide();
        this.set('showModal', true);
      }
    }
  }
});
