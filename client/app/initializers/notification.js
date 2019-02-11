export function initialize(application) {
  // application.inject('route', 'foo', 'service:foo');
  application.inject('route', 'notifications', 'service:notification');
  application.inject('controller', 'notifications', 'service:notification');
  application.inject('component', 'notifications', 'service:notification');
}

export default {
  initialize
};