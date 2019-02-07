import Route from '@ember/routing/route';
import { inject as service } from '@ember/service';
import { hash } from 'rsvp';
import { A } from '@ember/array';

export default Route.extend({
  session: service(),
  model() {
    return hash({
      team: this.modelFor('app.teams.team'),
      members: this.modelFor('app.teams.team').get('members'),
      currentUser: this.get('session').get('currentUser')
    });
  },
  setupController(controller, models) {
    this._super(controller, models);

    controller.setProperties({
      confirmRemoveModal: false,
      showAddTeamMembersModal: false,
      adminWarning: false,
    });

    controller.set('isAdmin', models.team.get('admins').includes(models.currentUser));
    controller.set('teamMemberEmails', A());
    controller.set('newMemberIndex', 2);
    controller.get('teamMemberEmails').pushObject({
      email: "",
      index: 1
    });
  }
});
