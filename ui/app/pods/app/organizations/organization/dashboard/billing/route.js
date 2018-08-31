import Ember from 'ember';
import RSVP from 'rsvp';
import config from 'mirror/config/environment';

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
        //message = message || "Updating Payment Method...";
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
            card.set('zip_code', token.card.address_zip);
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
                this.send('invalidateApplicationModel');
                this.toggleLoadingScreen();
            }).catch((error) => {
                this.toggleLoadingScreen();
                this.get('notificationCenter').error({
                    title: config.ERROR_MESSAGES.generic,
                    message: "We experienced an unexpected error trying to delete your payment method. Please try again."
                });
            }); 
        },
        makeDefaultBillingInformation(card) {
            this.toggleLoadingScreen("Updating Payment Method...");
            var organization = card.get('organization');
            organization.then((org) => { 
                const pre_default_payment = org.get('default_payment');
                org.set('default_payment', card);
                org.save().then(() => {
                    this.toggleLoadingScreen();
                }).catch((error) => {
                    this.toggleLoadingScreen();
                    org.reload();
                    this.get('notificationCenter').error({
                        title: config.ERROR_MESSAGES.generic,
                        message: "We experienced an unexpected error trying to update your default payment method. Please try again."
                    });
                });
            });
        },
        updateBillingFrequency() {
            this.toggleLoadingScreen("Updating Billing Frequency...");
            let organization = this.controller.get('model').organization;
            let billingFrequency = $(`input[name="billing-freq-${organization.get('id')}"]:checked`).val();

            organization.set('billing_frequency', billingFrequency);

            organization.save().then(() => {
                this.toggleLoadingScreen();
            }).catch((error) => {
                this.toggleLoadingScreen();
                this.get('notificationCenter').error({
                    title: config.ERROR_MESSAGES.generic,
                    message: "We experienced an unexpected error trying to update your billing frequency. Please try again."
                });
            }); 
        }
    }
});
