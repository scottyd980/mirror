import Ember from 'ember';
import config from '../../../config/environment';

export default Ember.Component.extend({
    stripe: null,
    card: null,
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
    
    stripeTokenHandler(token) {
       console.log(token);
    },
    actions: {
        processCreditCard() {
            var _this = this;
            let stripe = _this.get('stripe'),
                card = _this.get('card');

            let extra_details = {
                name: _this.get('customer_name')
            };

            stripe.createToken(card, extra_details).then(function(result) {
                if (result.error) {
                    // Inform the user if there was an error
                    var errorElement = document.getElementById('card-errors');
                    errorElement.textContent = result.error.message;
                } else {
                    // Send the token to your server
                    _this.stripeTokenHandler(result.token);
                }
            });
        }
    }
});
