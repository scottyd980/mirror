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
    const retrospective = this.get('store').findRecord('retrospective', params.id).catch(() => {
      throw ENV.ERROR_CODES.not_found;
    });

    const team = retrospective.then((retrospective) => {
      return retrospective.get('team');
    }).catch(() => {
      throw ENV.ERROR_CODES.not_found;
    });

    const team_members = team.then((team) => {
      return team.get('members');
    }).catch(() => {
      throw ENV.ERROR_CODES.not_found;
    });

    // TODO: Remove this?
    const currentUser = this.get('session').get('currentUser');

    const isModerator = retrospective.then((retrospective) => {
      return currentUser.get('id') === retrospective.get('moderator.id');
    });

    return hash({
      retrospective: retrospective,
      team: team,
      team_members: team_members,
      currentUser: currentUser,
      isModerator: isModerator
    });
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

    this.get('retroSvc').join_retrospective_channel(model.retrospective.get('id'));

    $(window).on('navigationListener', function (e) {
      _this.updateRetrospectiveState(e);
    });

    if (model.isModerator) {
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