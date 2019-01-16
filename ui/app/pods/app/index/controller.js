import Ember from 'ember';
import ENV from 'mirror/config/environment';

export default Ember.Controller.extend({
  billing_active: ENV.FLAGS.billing
});
