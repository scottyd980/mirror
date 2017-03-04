import Ember from 'ember';

export default Ember.Component.extend({
    stripe: Ember.inject.service(),
    card: null,
    didInsertElement() {
        var _this = this;
        var stripe = Stripe('pk_test_vd8mdRI6jcKLykIaVSgQCRwz');
        var elements = stripe.elements();
        var card = elements.create('card');
        card.mount('#card-element');

        // Create a token when the form is submitted.
        var form = document.getElementById('payment-form');
        form.addEventListener('submit', function(e) {
            e.preventDefault();
            _this.send('createToken', stripe, card);
        });
    },
    stripeTokenHandler(token) {
       console.log(token);
    },
    actions: {
        createToken(stripe, card) {
            var _this = this;
            stripe.createToken(card).then(function(result) {
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
