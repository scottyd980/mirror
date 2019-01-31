import EmberRouter from '@ember/routing/router';
import config from './config/environment';

const Router = EmberRouter.extend({
  location: config.locationType,
  rootURL: config.rootURL
});

Router.map(function() {
  this.route('auth', function() {
    this.route('login');
    this.route('register');

    this.route('forgot', function() {
      this.route('password');
      this.route('username');
    });

    this.route('reset', function() {
      this.route('password');
    });
  });
  this.route('app', function() {});
});

export default Router;
