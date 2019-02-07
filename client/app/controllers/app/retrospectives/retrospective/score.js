import RetrospectiveController from 'mirror/controllers/app/retrospectives/extends/retrospective';
import { inject as service } from '@ember/service';
import $ from 'jquery';
import ENV from 'mirror/config/environment';
import fetch from 'fetch';

export default RetrospectiveController.extend({
  session: service(),
  uuid: service(),
  submitted: false,
  score: null,

  submitScore(uuid) {
    const score = this.store.createRecord('score');
    const sprintScore = $('input[name="sprintScore"]:checked').val();

    if (typeof sprintScore !== "undefined") {
      score.set('score', sprintScore);
      score.set('retrospective', this.get('model').parent.retrospective);
      score.set('user', this.get('session').get('currentUser'));
      score.set('uuid', uuid);

      $('#score-submit').html("<i class='fa fa-fw fa-refresh fa-spin'></i> Submitting Score...");
      $('#score-submit').prop('disabled', true);

      score.save().then(() => {
        this._markScoreSubmitted();
      });
    } else {
      this.get('notifications').error({
        title: ENV.ERROR_MESSAGES.process,
        message: "You must select a score before submitting. Please try again."
      });
    }
  },
  _markScoreSubmitted(score) {
    if (score) {
      this.set('score', score);
    }
    this.set('submitted', true);
  },

  actions: {
    submitScore() {
      const uuid = this.get('uuid').get('hash');
      if (uuid) {
        this.submitScore(uuid);
      } else {
        fetch(`${ENV.DS.host}/${ENV.DS.namespace}/uuid`, {
          type: 'GET',
          headers: {
            'Authorization': `Bearer ${this.get('session').get('session.content.authenticated.access_token')}`
          }
        }).then((response) => {
          if (response.status === 200) {
            response.json().then((uuid) => {
              this.get('uuid').set('hash', uuid.hash);
              this.submitScore(uuid.hash);
            });
          } else {
            throw new Error('Unexpected response from server');
          }
        }).catch(() => {
          this.get('notifications').error({
            title: ENV.ERROR_MESSAGES.process,
            message: "There was a problem submitting your score. Please try again."
          });
        });
      }
    }
  }
});
