import EmberRouter from '@ember/routing/router';
import config from './config/environment';
import { inject as service } from '@ember/service';
import { scheduleOnce } from '@ember/runloop';

const Router = EmberRouter.extend({
  location: config.locationType,
  rootURL: config.rootURL,
  metrics: service(),
  didTransition() {
    this._super(...arguments);
    try {
      this._trackPage();
    } catch(e) {
      // Ignore errors if tracking fails
    }
    window.scrollTo(0, 0);
  },
  _trackPage() {
    scheduleOnce('afterRender', this, () => {
      const page = this.get('url');
      const title = this.getWithDefault('currentRouteName', 'unknown');

      this.get('metrics').trackPage({ page, title });
    });
  }
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

        this.route('three-little-pigs', function() {
          this.route('board-sticks');
          this.route('board-bricks');
          this.route('board-straw');
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

  this.route('policy', function() {
    this.route('terms-of-service');
    this.route('privacy');
  });
});

export default Router;
