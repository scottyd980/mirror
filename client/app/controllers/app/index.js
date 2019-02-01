import Controller from '@ember/controller';
import ENV from 'mirror/config/environment';

export default Controller.extend({
  billing_active: ENV.FLAGS.billing,
  actions: {
    viewOrganization(organization) {
      this.transitionToRoute('app.organizations.organization.dashboard', organization);
    },
    viewTeam(team) {
      this.transitionToRoute('app.teams.team.dashboard.retrospectives', team);
    },
  }
});
