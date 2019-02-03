import Route from '@ember/routing/route';
import { hash } from 'rsvp';
import { inject as service } from '@ember/service';

export default Route.extend({
  session: service(),
  model() {
    return hash({
      team: this.modelFor('app.teams.team'),
      retrospectives: this.store.query('retrospective', {
        filter: {
          team: this.modelFor('app.teams.team').get('id')
        }
      }),
      // TODO: Remove?
      currentUser: this.get('session').get('currentUser')
    });
  },
  setupController(controller, model) {
    this._super(...arguments);

    const retrospectives = model.retrospectives;

    retrospectives.map((retro) => {
      return retro.get('scores').then((scores) => {
        let averageScore = Math.round((scores.reduce((total, score) => {
          return total + score.get('score');
        }, 0) / scores.length) * 10) / 10;

        let scoreType = function () {
          if (averageScore) {
            if (averageScore > 6.67) {
              return "success";
            } else if (averageScore > 3.34) {
              return "warning";
            } else {
              return "danger";
            }
          } else {
            return "info";
          }
        }();

        retro.set('averageScore', averageScore);
        retro.set('scoreType', scoreType);
      });
    });

    controller.set('isAdmin', model.team.get('admins').includes(model.currentUser));
  }
});