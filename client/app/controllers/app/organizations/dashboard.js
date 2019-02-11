import Controller from '@ember/controller';

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
    viewOrganization(organization) {
      this.transitionToRoute('app.organizations.organization.dashboard', organization);
    },
    deleteOrganization(organization) {
      this.toggleLoadingScreen("Deleting Organization...");
      organization.destroyRecord().then(() => {
        this.toggleLoadingScreen();
        this.send('invalidateApplicationModel');
      });
    },

  }
});
