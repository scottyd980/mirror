import Controller from '@ember/controller';
import $ from 'jquery';

export default Controller.extend({
  loadingMessage: null,
  currentlyLoading: false,
  toggleLoadingScreen(message) {
    this.set('loadingMessage', message);
    this.toggleProperty('currentlyLoading');
  },
  actions: {
    toggleLoadingScreen(message) {
      this.toggleLoadingScreen(message);
    },
    updateTeam(team) {
      this.toggleLoadingScreen("Updating Team Preferences...");
      let isAnonymous = $(`input[name="is-anon-${team.get('id')}"]:checked`).val() === "true" ? true : false;
      team.set('isAnonymous', isAnonymous);
      team.save().then(() => {
        this.toggleLoadingScreen();
      });
    },
    deleteTeam(team) {
      this.toggleLoadingScreen("Deleting Team...");
      team.destroyRecord().then(() => {
        this.toggleLoadingScreen();
        this.send('invalidateApplicationModel');
        this.transitionTo('app');
      });
    },
    onConfirm(message, action) {
      this.get('notifications').confirmAction(message, action);
    }
  }
});
