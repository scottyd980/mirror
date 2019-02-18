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
      this.route('password', { path: '/password/:uuid' });
    });
  });
  this.route('app', function() {
    this.route('teams', function() {
      this.route('create');
      this.route('join');
      this.route('access', { path: '/join/:access_code' });
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
      this.route('history', { path: '/history/:id' });
      this.route('retrospective', { path: '/:id' }, function() {
        this.route('start');
        this.route('score');
        this.route('aggregate');
        this.route('feedback');
        this.route('summary');

        this.route('sticky-notes', function() {
          this.route('board-negative');
          this.route('board-positive');
        });
      });
    });

    if(config.FLAGS.billing) {
      this.route('organizations', function() {
        this.route('create');

        this.route('organization', { path: '/:id' }, function() {
          this.route('dashboard', function() {
            this.route('billing');
            this.route('teams');
          });
        });
        this.route('dashboard');
      });
    }
  });

  this.route('demo', function() {
    this.route('start');
    this.route('feedback');

    this.route('sticky-notes', function() {
      this.route('board-negative');
      this.route('board-positive');
    });
    this.route('score');
    this.route('aggregate');
    this.route('summary');
  });
});

export default Router;
