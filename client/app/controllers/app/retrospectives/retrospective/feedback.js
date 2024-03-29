import RetrospectiveController from 'mirror/controllers/app/retrospectives/extends/retrospective';
import { inject as service } from '@ember/service';
import { Promise } from 'rsvp';
import fetch from 'fetch';
import ENV from 'mirror/config/environment';
import { set, computed } from '@ember/object';

export default RetrospectiveController.extend({
  session: service(),
  uuid: service(),

  feedbackInput: computed('model.gameInput', function() {
    const chunkSize = 2;
    const gameInput = this.get('model.gameInput');

    let chunks = [];
    for (let i=0,len=gameInput.length; i<len; i+=chunkSize) {
      chunks.push(gameInput.slice(i, i+chunkSize));
    }
    return chunks;
  }),

  submitted: false,

  submitFeedback(uuid) {
    let feedbackToSubmit = [];

    this.get('model').gameInput.forEach((feedback) => {
      if (feedback.value.trim() !== "") {
        const fb = this.store.createRecord('feedback', {
          category: feedback.type,
          message: feedback.value,
          user: this.get('session').get('currentUser'),
          retrospective: this.get('model').retrospective,
          uuid: uuid
        });

        feedbackToSubmit.push(fb.save());
      }
    });

    Promise.all(
      feedbackToSubmit
    ).then(() => {
      this._markFeedbackSubmitted();
    }).catch(() => {
      this.get('notifications').error({
        title: ENV.ERROR_MESSAGES.process,
        message: "There was a problem submitting your feedback. Please try again."
      });
    });
  },
  _markFeedbackSubmitted(feedbacks) {
    if (feedbacks) {
      this.get('model').gameInput.forEach((input) => {
        set(input, 'value', feedbacks.find((feedback) => {
          return feedback.get('category') === input.type;
        }).get('message'));
      });
    }
    this.set('submitted', true);
  },

  actions: {
    submitFeedback() {
      const feedbackExists = this.get('model').gameInput.some((feedback) => {
        return (feedback.value.trim() !== "") ? true : false;
      });

      if(feedbackExists) {
        const uuid = this.get('uuid').get('hash');
        if (uuid) {
          this.submitFeedback(uuid);
        } else {
          fetch(`${ENV.DS.host}/${ENV.DS.namespace}/uuid`, {
            type: 'GET',
            headers: {
              'Authorization': `Bearer ${this.get('session').get('session.content.authenticated.access_token')}`
            }
          }).then((response) => {
            if (response.status === 200 || response.status === 201) {
              response.json().then((uuid) => {
                this.get('uuid').set('hash', uuid.hash);
                this.submitFeedback(uuid.hash);
              });
            } else {
              throw new Error('Unexpected response from server');
            }
          }).catch(() => {
            this.get('notifications').error({
              title: ENV.ERROR_MESSAGES.process,
              message: "There was a problem submitting your feedback. Please try again."
            });
          });
        }
      } else {
        this.get('notifications').error({
          title: ENV.ERROR_MESSAGES.process,
          message: "You must enter some feedback before submitting. Please enter some feedback and try submitting again."
        });
      }
    }
  }
});
