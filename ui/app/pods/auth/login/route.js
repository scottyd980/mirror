import Ember from 'ember';

const { inject } = Ember;

export default Ember.Route.extend({
  session: inject.service(),
  model() {
    return {
      username: '',
      password: ''
    };
  },
  actions: {
    doLogin() {
      const user = this.get('currentModel');
      this.get('session')
        .authenticate(
          'authenticator:mirror', user.username, user.password
        );
    }
  }
});
