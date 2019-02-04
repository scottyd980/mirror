import Controller from '@ember/controller';
import ENV from 'mirror/config/environment';
import { observer } from '@ember/object'

export default Controller.extend({
  initialState: null,
  retrospectiveStateChanged: observer('model.retrospective.state', function () {
    const state = this.get('model.retrospective.state');

    //TODO: Will eventually want to make game type dynamic as well
    const dynamicRouteSegment = ENV.retrospective.sticky_notes.states[state];
    this.transitionToRoute('app.retrospectives.retrospective.' + dynamicRouteSegment, this.get('model'));
  }),
  retrospectiveCancelled: observer('model.retrospective.cancelled', function () {
    const cancelled = this.get('model.retrospective.cancelled'),
          team = this.get('model.retrospective.team');

    if (cancelled) {
      if (parseInt(this.get('model.retrospective.moderator.id')) !== parseInt(this.get('model.current_user.id'))) {
        this.transitionToRoute('app.teams.team.dashboard.retrospectives', team).then(() => {
          this.get('notifications').success({
            title: "Retrospective Cancelled",
            message: "The retrospective was cancelled or removed by the moderator or a team admin."
          });
        });
      }
    }
  })
});
