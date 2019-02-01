import Route from '@ember/routing/route';
import { hash } from 'rsvp';
import { inject as service } from '@ember/service';

export default Route.extend({
  session: service(),
  model() {
    const _this = this;
    return hash({
      team: this.modelFor('app.teams.team'),
      currentUser: _this.get('session.currentUser')
    });
  },
  setupController(controller, model) {
    const _this = this;
    _this._super(controller, model);

    controller.set('isAdmin', model.team.get('admins').includes(model.currentUser));
  }
});
