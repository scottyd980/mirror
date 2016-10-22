import Ember from 'ember';
import config from './config/environment';

const Router = Ember.Router.extend({
  location: config.locationType,
  rootURL: config.rootURL
});

Router.map(function() {
  this.route('auth', function() {
    this.route('login');
    this.route('register');
  });
  this.route('app', function() {
    this.route('teams', function() {
      this.route('create');
      this.route('team', { path: '/:id' }, function() {
        this.route('dashboard', function() {
          this.route('index');
          this.route('members');
          this.route('history');
        });
      });
    });
  });
});

export default Router;
