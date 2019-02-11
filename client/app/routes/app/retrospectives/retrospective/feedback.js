import Route from '@ember/routing/route';
import ENV from 'mirror/config/environment';
import { hash } from 'rsvp';
import { inject as service } from '@ember/service';
import { set } from '@ember/object';

export default Route.extend({
  session: service(),
  model() {
    const parent = this.modelFor('app.retrospectives.retrospective')

    return this.get('store').findRecord('retrospective', parent.retrospective.get('id'))
    .then((retrospective) => {
      return Promise.all([retrospective.get('team'), retrospective.get('feedbacks'), retrospective.get('feedbackSubmissions')]).then((results) => {
        const team = results[0],
              feedback = results[1],
              feedbackSubmissions = results[2];
        
        return team.get('members').then((team_members) => {
          return hash({
            retrospective,
            team,
            team_members,
            feedback,
            feedbackSubmissions,
            gameInput: ENV.retrospective["sticky_notes"].feedback
          });
        }).catch(() => { throw ENV.ERROR_CODES.not_found});
      },
      () => { throw ENV.ERROR_CODES.not_found; });
    }).catch(() => { throw ENV.ERROR_CODES.not_found });
  },
  setupController(controller, model) {
    this._super(...arguments);
    
    const feedback = model.feedback;

    controller.set('submitted', false);

    model.gameInput.forEach((feedback) => {
      set(feedback,'value', '');
    });

    const userFeedback = feedback.filter((fb) => {
      return parseInt(fb.get('user.id')) === parseInt(this.get('session').get('currentUser.id'));
    });

    if (typeof userFeedback !== "undefined" && userFeedback.length > 0) {
      this._markFeedbackSubmitted(userFeedback);
    }
  },
  _markFeedbackSubmitted(feedbacks) {
    if (feedbacks) {
      this.currentModel.gameInput.forEach((input) => {
        set(input, 'value', feedbacks.find((feedback) => {
          return feedback.get('category') === input.type;
        }).get('message'));
      });
    }
    this.controller.set('submitted', true);
  },
});