import Route from '@ember/routing/route';
import { hash } from 'rsvp';
import ENV from 'mirror/config/environment';
import { inject as service } from '@ember/service';
import $ from 'jquery';

export default Route.extend({
  session: service(),
  socket: service(),
  retroSvc: service('retrospective'),
  model(params) {
    return this.get('store').findRecord('retrospective', params.id)
    .then((retrospective) => {
      return retrospective.get('team').then((team) => {
        return team.get('members').then((team_members) => {
          return hash({
            retrospective,
            team,
            team_members
          });
        }).catch(() => { throw ENV.ERROR_CODES.not_found});
      }).catch(() => { throw ENV.ERROR_CODES.not_found});
    }).catch(() => { throw ENV.ERROR_CODES.not_found});
  },
  redirect(model) {
    const state = model.retrospective.get('state');
    // TODO: Dynamic depending on game
    const dynamicRouteSegment = ENV.retrospective.sticky_notes.states[state];
    this.transitionTo('app.retrospectives.retrospective.' + dynamicRouteSegment);
  },
  setupController(controller, model) {
    this._super(...arguments);
    const _this = this;

    controller.set('hasRetroInProgress', false);
    controller.set('isRetroStartModalShowing', false);
    controller.set('isActionModalShowing', false);
    controller.set('actionMessage', '');

    this.get('retroSvc').join_retrospective_channel(model.retrospective);

    $(window).on('navigationListener', function (e) {
      _this.updateRetrospectiveState(e);
    });

    const isModerator = this.get('session.currentUser.id') === model.retrospective.get('moderator.id');

    if (isModerator) {
      $(window).on('popstate', function (e) {
        $(window).trigger('navigationListener', [e]);
      });
    }
  },
  deactivate() {
    this.get('retroSvc').leave_retrospective_channel(this.get('currentModel').retrospective.get('id'));
    $(window).off('navigationListener');
  },
  updateRetrospectiveState() {
    const retrospective = this.get('currentModel').retrospective;
    const path = window.location.pathname;
    if (path.startsWith('/app/retrospectives/')) {
      const stateSegment = path.replace(/\/app\/retrospectives\/\d+\//, '').replace(/\//g, ".");
      const state = ENV.retrospective.sticky_notes.states.indexOf(stateSegment);

      retrospective.set('state', state);
      retrospective.save();
    }
  }
});