import Route from '@ember/routing/route';
import { hash } from 'rsvp';
import ENV from 'mirror/config/environment';

export default Route.extend({
  model() {
    const parent = this.modelFor('app.retrospectives.retrospective')

    return this.get('store').findRecord('retrospective', parent.retrospective.get('id'))
    .then((retrospective) => {
      return Promise.all([retrospective.get('team'), retrospective.get('feedbacks'), ]).then((results) => {
        const team = results[0],
              feedback = results[1];

        const bricksFeedback = this._shuffle(feedback.filter((fb) => {
          return fb.get('category') === "brick";
        }));
        
        return team.get('members').then((team_members) => {
          return hash({
            retrospective,
            team,
            team_members,
            feedback: bricksFeedback
          });
        }).catch(() => { throw ENV.ERROR_CODES.not_found});
      },
      () => { throw ENV.ERROR_CODES.not_found; });
    }).catch(() => { throw ENV.ERROR_CODES.not_found });
  },
  _shuffle(array) {
    let currentIndex = array.length, temporaryValue, randomIndex;
    while (0 !== currentIndex) {
      randomIndex = Math.floor(Math.random() * currentIndex);
      currentIndex -= 1;

      temporaryValue = array[currentIndex];
      array[currentIndex] = array[randomIndex];
      array[randomIndex] = temporaryValue;
    }

    return array;
  }
});