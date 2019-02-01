import Component from '@ember/component';
import ENV from 'mirror/config/environment';

export default Component.extend({
  tagName: "",
  hideDelete: false,
  active_billing_types: ENV.ACTIVE_BILLING_TYPES
});
