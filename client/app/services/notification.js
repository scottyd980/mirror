import Service from '@ember/service';
import { inject as service } from '@ember/service';
import ENV from 'mirror/config/environment';

export default Service.extend({
  router: service(),
  notifications: null,

  init() {
    this._super(...arguments);
    this.set('notifications', []);
    this.router.on('routeWillChange', () => {
      this.currentPathDidChange();
    });
  },
  success(notification) {
    this.clear();
    notification.type = "success";
    this.get('notifications').pushObject(notification);
  },
  error(notification) {
    this.clear();
    notification.type = "error";
    this.get('notifications').pushObject(notification);
  },
  confirm(notification) {
    this.clear();
    notification.type = "confirm";
    this.get('notifications').pushObject(notification);
  },
  clear() {
    this.get('notifications').clear();
  },
  currentPathDidChange: function () {
    this.clear();
  },
  confirmAction(message, action, title) {
    this.confirm({
      title: title || ENV.CONFIRM_MESSAGES.generic,
      message: message,
      action: action
    });
  },
  closeConfirm(action) {
    this.clear();
    action();
  }
});