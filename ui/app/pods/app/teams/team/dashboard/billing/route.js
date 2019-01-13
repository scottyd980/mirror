import Ember from 'ember';
import RSVP from 'rsvp';
import config from '../../../../../../config/environment';

export default Ember.Route.extend({
    session: Ember.inject.service('session'),
    model() {
        var _this = this;
        return RSVP.hash({
            team: _this.modelFor('app.teams.team'),
            user_organizations: this.get('session.currentUser').get('organizations'),
            currentUser: _this.get('session').get('currentUser')
        });
    },
    toggleLoadingScreen(message) {
        this.controller.set('loadingMessage', message);
        this.controller.toggleProperty('currentlyLoading');
    },
    setupController(controller) {
        this._super(...arguments);
        controller.set('isJoinOwnOrganizationModalShowing', false);
        controller.set('isCreateNewOrganizationModalShowing', false);
        controller.set('isJoinAnotherOrganizationModalShowing', false);
        controller.set('newOrganizationName', '');
        controller.set('orgError', '');

        controller.set('active_billing_types', config.ACTIVE_BILLING_TYPES);
    },
    actions: {
        toggleJoinOwnOrganizationModal() {
            this.controller.set('orgError', '');
            this.controller.toggleProperty('isJoinOwnOrganizationModalShowing');
        },
        toggleCreateNewOrganizationModal() {
            this.controller.set('orgError', '');
            this.controller.toggleProperty('isCreateNewOrganizationModalShowing');
        },
        toggleJoinAnotherOrganizationModal() {
            this.controller.toggleProperty('isJoinAnotherOrganizationModalShowing');
        },
        createOrganization() {
            var _this = this;

            _this.controller.set('orgError', '');

            if(!_this.controller.get('newOrganizationName') || _this.controller.get('newOrganizationName').trim() === "") {
                _this.controller.set('orgError', 'Your organization needs a name!');
                return;
            }

            var newOrganization = this.store.createRecord('organization');

            var admins = [_this.get('session').get('currentUser')];
            var members = [_this.get('session').get('currentUser')];
            var teams = [_this.get('currentModel').team];

            newOrganization.set('admins', admins);
            newOrganization.set('members', members);
            newOrganization.set('teams', teams);
            newOrganization.set('name', this.controller.get('newOrganizationName'));


            _this.send('toggleCreateNewOrganizationModal');
            _this.toggleLoadingScreen('Creating Organization...');
            newOrganization.save().then((organization) => {
                _this.get('currentModel').team.set('organization', organization);
                _this.get('currentModel').team.save();
                this.toggleLoadingScreen();
            });
        },
        joinOwnOrganization() {
            let organization = $('input[name="billing-add-organization"]:checked').val();
            let user_organizations = this.get('currentModel').user_organizations;

            if(typeof organization !== "undefined") {

                let team_organization = user_organizations.find((org) => {
                    return org.id === organization;
                });

                this.get('currentModel').team.set('organization', team_organization);
                this.send('toggleJoinOwnOrganizationModal');
                this.toggleLoadingScreen('Joining Organization...');
                this.get('currentModel').team.save().then(() => {
                    this.toggleLoadingScreen();
                });
            
            } else {
                this.controller.set('orgError', 'You need to select an organization!');
            }
        }
    }
});
