import Ember from 'ember';
import config from '../../../config/environment';

export default Ember.Component.extend({
    stripe: null,
    card: null,
    loadMethod: null,
    didInsertElement() {
        let _this = this;
        let stripe, elements, card;

        _this.set('stripe', Stripe(config.stripe.publishableKey));
        stripe = _this.get('stripe');
        
        elements = stripe.elements();
        _this.set('card', elements.create('card', {
            hidePostalCode: true,
        }));

        card = _this.get('card');
        card.mount('#org-billing-card');
    },
    
    actions: {
        processCreditCard() {
            if(this.get('loadMethod')) {
                this.get('loadMethod')();
            }
            var _this = this;
            let stripe = _this.get('stripe'),
                card = _this.get('card');

            let extra_details = {
                name: _this.get('customer_name'),
                address_zip: _this.get('zipcode')
            };

            stripe.createToken(card, extra_details).then(function(result) {
                if (result.error) {
                    // Inform the user if there was an error
                    var errorElement = document.getElementById('card-errors');
                    errorElement.textContent = result.error.message;
                } else {
                    _this.get('afterSubmission')(result.token);
                }
            });
        }
    }
});
