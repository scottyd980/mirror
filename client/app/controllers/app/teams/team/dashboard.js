import Controller from '@ember/controller';
import ENV from 'mirror/config/environment';

export default Controller.extend({
  billing_active: ENV.FLAGS.billing
});
