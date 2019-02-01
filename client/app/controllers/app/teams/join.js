import Controller from '@ember/controller';

export default Controller.extend({
  actions: {
    joinTeam() {
      let accessCode = this.get('accessCode');
      this.transitionToRoute('app.teams.access', accessCode);
    }
  }
});
