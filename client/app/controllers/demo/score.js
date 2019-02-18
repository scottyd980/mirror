import { later } from '@ember/runloop';
import ENV from 'mirror/config/environment';
import RetrospectiveController from 'mirror/controllers/demo/extends/retrospective';
import $ from 'jquery';

export default RetrospectiveController.extend({
  submitted: false,
  showModal: false,

  begin_score: function() {
    later(this, function() {
      this.get('model.scoreSubmissions').pushObject(ENV.DEMO.score_submissions[0]);
      later(this, function() {
        this.get('model.scoreSubmissions').pushObject(ENV.DEMO.score_submissions[1]);
      }, 900);
    }, 500);
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