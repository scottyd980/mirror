import Controller from '@ember/controller';
import ENV from 'mirror/config/environment';
import { observer } from '@ember/object'

export default Controller.extend({
  initialState: null,
  retrospectiveStateChanged: observer('model.retrospective.state', function () {
    const state = this.get('model.retrospective.state');
    const current_game = Object.keys(ENV.retrospective).find(key => ENV.retrospective[key].type_id === this.get('model.retrospective.game'));
    
    const dynamicRouteSegment = ENV.retrospective[current_game].states[state];
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
