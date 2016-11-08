export function initialize(application) {
  application.inject('route', 'notificationCenter', 'service:notification-service');
  application.inject('controller', 'notificationCenter', 'service:notification-service');
}

export default {
  name: 'notification-service',
  initialize
};
