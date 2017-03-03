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
      this.route('join');
      this.route('access', {path: '/join/:access_code'});

      this.route('team', { path: '/:id' }, function() {
        this.route('dashboard', function() {
          this.route('members');
          this.route('history');
          this.route('retrospectives');
          this.route('preferences');
          this.route('billing');
        });
      });
    });

    this.route('retrospectives', function() {
      this.route('retrospective', { path: '/:id' }, function() {
        this.route('start');
        this.route('score');
        this.route('aggregate');
        this.route('feedback');

        this.route('sticky-notes', function() {
          this.route('board-negative');
          this.route('board-positive');
        });
        this.route('summary');
      });

      this.route('history', { path: '/history/:id' });
    });

    this.route('users', function() {
      this.route('profile');

      this.route('user', { path: '/:id' }, function() {
        this.route('profile');
      });
    });
    this.route('organizations', function() {
      this.route('create');

      this.route('organization', { path: '/:id'}, function() {
        this.route('dashboard', function() {
          this.route('teams');
          this.route('billing');
          this.route('members');
        });
      });
      this.route('dashboard');
    });
  });
});

export default Router;
