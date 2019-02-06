import Controller from '@ember/controller';
import ENV from 'mirror/config/environment';
import $ from 'jquery';

export default Controller.extend({
  isAdmin: false,
  currentlyLoading: false,
  loadingMessage: null,
  toggleLoadingScreen(message) {
    this.set('loadingMessage', message);
    this.toggleProperty('currentlyLoading');
  },
  actions: {
    newOrganizationBilling(token) {
      const card = this.store.createRecord('card');

      card.set('brand', token.card.brand);
      card.set('last4', token.card.last4);
      card.set('exp_month', token.card.exp_month);
      card.set('exp_year', token.card.exp_year);
      card.set('token_id', token.id);
      card.set('card_id', token.card.id);
      card.set('zip_code', token.card.address_zip);
      card.set('organization', this.get('model.organization'));
      card.save().then(() => {
        //TODO: TEST THESE
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
      }).catch(() => {
        this.toggleLoadingScreen();
        this.get('notifications').error({
          title: ENV.ERROR_MESSAGES.generic,
          message: "We experienced an unexpected error trying to delete your payment method. Please try again."
        });
      });
    },
    makeDefaultBillingInformation(card) {
      this.toggleLoadingScreen("Updating Payment Method...");
      var organization = card.get('organization');
      organization.then((org) => {
        org.set('default_payment', card);
        org.save().then(() => {
          this.toggleLoadingScreen();
        }).catch((error) => {
          this.toggleLoadingScreen();
          org.rollbackAttributes();
          org.reload();
          if (error.errors && Array.isArray(error.errors) && error.errors[0].code === 422) {
            this.get('notifications').error({
              title: ENV.ERROR_MESSAGES.generic,
              message: "It looks like their was an issue trying to update your card. Please make sure it's not expired and try again."
            });
          } else {
            this.get('notifications').error({
              title: ENV.ERROR_MESSAGES.generic,
              message: "We experienced an unexpected error trying to update your default payment method. Please try again."
            });
          }
        });
      });
    },
    updateBillingFrequency() {
      this.toggleLoadingScreen("Updating Billing Frequency...");
      let organization = this.get('model').organization;
      let billingFrequency = $(`input[name="billing-freq-${organization.get('id')}"]:checked`).val();

      organization.set('billing_frequency', billingFrequency);

      organization.save().then(() => {
        this.toggleLoadingScreen();
      }).catch(() => {
        this.toggleLoadingScreen();
        organization.rollbackAttributes();
        organization.reload();
        this.get('notifications').error({
          title: ENV.ERROR_MESSAGES.generic,
          message: "We experienced an unexpected error trying to update your billing frequency. Please try again."
        });
      });
    }
  }
});
