import Controller from '@ember/controller';

export default Controller.extend({
  isAdmin: false,
  loadingMessage: null,
  currentlyLoading: false,
  toggleLoadingScreen(message) {
    this.set('loadingMessage', message);
    this.toggleProperty('currentlyLoading');
  },
  actions: {
    viewTeam(team) {
      this.transitionToRoute('app.teams.team.dashboard.retrospectives', team);
    },
    toggleLoadingScreen(message) {
      this.toggleLoadingScreen(message);
    },
    removeTeam(team) {
      this.toggleLoadingScreen("Removing Team...");
      team.set('organization', null);
      team.save().then(() => {
        //this.send('invalidateApplicationModel');
        this.toggleLoadingScreen();
      }).catch((error) => {
        // TODO: Handle error
        this.toggleLoadingScreen();
      });
    }
  }
});
