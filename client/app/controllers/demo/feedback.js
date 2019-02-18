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

  actions: {
    close: function() {
      $('.tippy-popper').show();
      this.set('showModal', false);
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
          if(feedback.value.trim() !== "") {
            ENV.DEMO.user_feedback.pushObject({
              category: feedback.type,
              message: feedback.value,
              user: ENV.DEMO.current_user
            });
          }
        });
        this.set('submitted', true);
      } else {
        $('.tippy-popper').hide();
        this.set('showModal', true);
      }
    }
  }
});
