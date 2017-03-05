import Ember from 'ember';
import RSVP from 'rsvp';

export default Ember.Route.extend({
    session: Ember.inject.service('session'),
    model() {
        var _this = this;
        return RSVP.hash({
            organization: this.modelFor('app.organizations.organization'),
            currentUser: _this.get('session').get('currentUser')
        });
    },
    setupController(controller, models) {
        var _this = this;
        _this._super(controller, models);

        controller.set('isAdmin', models.organization.get('admins').includes(models.currentUser));
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
            card.save();
        }
    }
});
