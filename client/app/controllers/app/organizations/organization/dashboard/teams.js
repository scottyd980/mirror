import Controller from '@ember/controller';
import ENV from 'mirror/config/environment';

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
        this.toggleLoadingScreen();
      }).catch(() => {
        this.toggleLoadingScreen();
        this.get('notifications').error({
          title: ENV.ERROR_MESSAGES.generic,
          message: "We experienced an unexpected error trying to remove the team from your organization. Please try again."
        });
      });
    }
  }
});
