import Route from '@ember/routing/route';
import RSVP from 'rsvp';
import ENV from 'mirror/config/environment';
import { inject as service } from '@ember/service';

export default Route.extend({
  session: service(),
  beforeModel() {
    if(this.get('session.isAuthenticated') && !this.get('session.currentUser')) {
      return fetch(`${ENV.DS.host}/${ENV.DS.namespace}/user/current`, {
        type: 'GET',
        headers: {
          'Authorization': `Bearer ${this.get('session').get('session.content.authenticated.access_token')}`
        }
      }).then((raw) => {
        return raw.json().then((data) => {
          const currentUser = this.store.push(data);
          this.set('session.currentUser', currentUser);
        });
      });
    } else {
      return;
    }
  },
  model() {
    const current_user = this.get('session.currentUser');

    return RSVP.hash({
      teams: current_user.get('teams').sortBy('id'),
      organizations: (ENV.FLAGS.billing ? current_user.get('organizations').sortBy('id') : null),
      recent_retrospectives: current_user.get('teams').then((teams) => {
        const retros = teams.map((team) => {
          return this.store.query('retrospective', {
            filter: {
              team: team.get('id')
            }
          });
        });

        return RSVP.allSettled(retros).then((retrospectives) => {
          let retro_list = retrospectives.reduce((retro_arr, retrospective) => {
            return retro_arr.concat(retrospective.value.toArray());
          }, []);

          return retro_list.sortBy('updatedAt').reverse().slice(0, 10);
        });

      })
    });
  },
  setupController(controller, model) {
    this._super(controller, model);

    const retrospectives = model.recent_retrospectives;

    // TODO: there should be a better / more efficient way to do this
    retrospectives.map((retro) => {
      return retro.get('scores').then((scores) => {
        let averageScore = Math.round((scores.reduce((total, score) => {
          return total + score.get('score');
        }, 0) / scores.length) * 10) / 10;

        let scoreType = function () {
          if (averageScore) {
            if (averageScore > 6.67) {
              return "success";
            } else if (averageScore > 3.34) {
              return "warning";
            } else {
              return "danger";
            }
          } else {
            return "info";
          }
        }();

        retro.set('averageScore', averageScore);
        retro.set('scoreType', scoreType);
      });
    });
  }
});
