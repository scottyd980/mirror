import Ember from 'ember';
import RSVP from 'rsvp';

export default Ember.Route.extend({
    session: Ember.inject.service('session'),
    model() {
        var _this = this;
        return RSVP.hash({
            organization: this.modelFor('app.organizations.organization'),
            currentUser: _this.get('session').get('currentUser'),
            cards: _this.store.query('card', {
                filter: {
                    organization: _this.modelFor('app.organizations.organization').get('id')
                }
            })
        });
    },
    setupController(controller, models) {
        var _this = this;
        _this._super(controller, models);

        controller.set('isAdmin', models.organization.get('admins').includes(models.currentUser));
        controller.set('currentlyLoading', false);
    },
    toggleLoadingScreen(message) {
        this.controller.set('loadingMessage', message);
        this.controller.toggleProperty('currentlyLoading');
    },
    actions: {
        newOrganizationBilling(token) {
            let card = this.store.createRecord('card');

            card.set('brand', token.card.brand);
            card.set('last4', token.card.last4);
            card.set('exp_month', token.card.exp_month);
            card.set('exp_year', token.card.exp_year);
            card.set('token_id', token.id);
            card.set('card_id', token.card.id);
            card.set('organization', this.controller.get('model.organization'));
            card.save().then(() => {
                this.send('invalidateApplicationModel');
                this.toggleLoadingScreen();
            });
        },
        toggleLoadingScreen(message) {
            this.toggleLoadingScreen(message);
        },
        deleteBillingInformation(card) {
            this.toggleLoadingScreen("Removing Payment Method...");
            card.destroyRecord().then(() => {
                this.toggleLoadingScreen("Removing Payment Method...");
            });
        },
        editBillingInformation(card) {
            console.log(card);
        }
    }
});
