import Route from '@ember/routing/route';
import ENV from 'mirror/config/environment';
import { hash } from 'rsvp';
import { inject as service } from '@ember/service';

export default Route.extend({
  session: service(),
  model(params) { 
    const retrospective = this.get('store').findRecord('retrospective', params.id).catch(() => {
      throw ENV.ERROR_CODES.not_found;
    });

    const team = retrospective.then((retrospective) => {
      return retrospective.get('team');
    }).catch(() => {
      throw ENV.ERROR_CODES.not_found;
    });

    const team_members = team.then((team) => {
      return team.get('members');
    }).catch(() => {
      throw ENV.ERROR_CODES.not_found;
    });

    const scores = retrospective.then((retrospective) => {
      return retrospective.get('scores');
    }).catch(() => {
      throw ENV.ERROR_CODES.not_found;
    });

    const feedback = retrospective.then((retrospective) => {
      return retrospective.get('feedbacks');
    }).catch(() => {
      throw ENV.ERROR_CODES.not_found;
    });

    const currentUser = this.get('session').get('currentUser');

    return hash({
      retrospective: retrospective,
      team: team,
      team_members: team_members,
      currentUser: currentUser,
      scores: scores,
      feedback: feedback
    });
  },
  setupController(controller, model) {
    this._super(...arguments);

    let scores = model.scores.sortBy('score');

    let average = scores.reduce((total, score) => {
      return total + score.get('score');
    }, 0) / scores.length;

    controller.set('low_score', (typeof scores[0] !== "undefined" ? scores[0] : { score: "N/A" }));
    controller.set('high_score', (typeof scores[scores.length - 1] !== "undefined" ? scores[scores.length - 1] : { score: "N/A" }));
    controller.set('average_score', average || "N/A");
  }
});