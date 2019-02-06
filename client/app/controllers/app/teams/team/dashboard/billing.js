import Controller from '@ember/controller';
import $ from 'jquery';
import { inject as service } from '@ember/service';

export default Controller.extend({
  session: service(),
  toggleLoadingScreen(message) {
    this.set('loadingMessage', message);
    this.toggleProperty('currentlyLoading');
  },
  actions: {
    toggleJoinOwnOrganizationModal() {
      this.set('orgError', '');
      this.toggleProperty('isJoinOwnOrganizationModalShowing');
    },
    toggleCreateNewOrganizationModal() {
      this.set('orgError', '');
      this.toggleProperty('isCreateNewOrganizationModalShowing');
    },
    toggleJoinAnotherOrganizationModal() {
      this.toggleProperty('isJoinAnotherOrganizationModalShowing');
    },
    createOrganization() {
      this.set('orgError', '');

      if (!this.get('newOrganizationName') || this.get('newOrganizationName').trim() === "") {
        this.set('orgError', 'Your organization needs a name!');
        return;
      }

      const newOrganization = this.store.createRecord('organization');

      let admins = [this.get('session').get('currentUser')];
      let members = [this.get('session').get('currentUser')];
      let teams = [this.get('model').team];

      newOrganization.set('admins', admins);
      newOrganization.set('members', members);
      newOrganization.set('teams', teams);
      newOrganization.set('name', this.get('newOrganizationName'));

      this.send('toggleCreateNewOrganizationModal');
      this.toggleLoadingScreen('Creating Organization...');
      newOrganization.save().then((organization) => {
        this.get('model').team.set('organization', organization);
        this.get('model').team.save();
        this.toggleLoadingScreen();
      });
    },
    joinOwnOrganization() {
      const organization = $('input[name="billing-add-organization"]:checked').val();
      const user_organizations = this.get('model').user_organizations;

      if (typeof organization !== "undefined") {

        const team_organization = user_organizations.find((org) => {
          return org.id === organization;
        });

        this.get('model').team.set('organization', team_organization);
        this.send('toggleJoinOwnOrganizationModal');
        this.toggleLoadingScreen('Joining Organization...');
        this.get('model').team.save().then(() => {
          this.toggleLoadingScreen();
        });

      } else {
        this.set('orgError', 'You need to select an organization!');
      }
    }
  }
});
